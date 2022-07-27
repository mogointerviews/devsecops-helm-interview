#!/bin/bash

shopt -s extglob

DIRECTORY="$1"

if ! which yq || ! which helm ; then
	echo "yq, helm (version 3), mktemp and grep  must be installed for this script to operate!"
	exit 1
fi

[[ -d "$TMPDIR" ]] || $TMPDIR="${PWD}"

TEMPFILE=$(mktemp ${TMPDIR}/interview-validator.XXXXXX || exit 1)
TEMPFILE2=$(mktemp ${TMPDIR}/interview-validator.XXXXXX || exit 1)

[[ -d "$1" ]] || { echo "Usage: ${0} <directory to validate>" ; exit 1 ; }

if ! helm lint --strict ${DIRECTORY} ; then
     echo "Helm template in ${DIRECTORY} is not valid" 
     exit 1
fi

helm template ${DIRECTORY} | yq e -o json '.' - > $TEMPFILE || exit 1
helm template ${DIRECTORY} | yq e -o json '. | select(.kind == "ConfigMap"),select(.kind == "Ingress"),select(.kind == "Deployment"),select(.kind == "Service"),select(.kind == "Secret")' - > $TEMPFILE2 || exit 1

TEMPLATEDIFF="$(diff -u $TEMPFILE $TEMPFILE2)"

if [[ -n "$TEMPLATEDIFF" ]] ; then
	echo "$TEMPLATEDIFF" | grep kind | grep -- -
	echo "You can only use kubernetes objects of type ConfigMap, Ingress, Deployment, Service or Secret in your chart!"
	rm -f $TEMPFILE $TEMPFILE2
	exit 1
fi

rm -f $TEMPFILE $TEMPFILE2

if ! grep -q '{{ .Values.Port }}' ${DIRECTORY}/templates/Ingress.yaml ||
	! grep -q '{{ .Values.Name }}' ${DIRECTORY}/templates/Ingress.yaml ||
	! grep -q '{{ .Values.Domain }}' ${DIRECTORY}/templates/Ingress.yaml || 
	! grep -q '{{ .Values.HealthCheckUrl }}' ${DIRECTORY}/templates/Deployment.yaml  ; then
	echo "You must use the name Name, Domain, Ports and HealthCheckUrl from the values.yaml in order for the chart to be able to be installed!"
	exit 1
fi

echo "Success! The helm chart in ${DIRECTORY} appears to be valid."
