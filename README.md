# DevSecOps Helm Interview

To use this repo, fork it, then check it out to your local machine. This exercise requires git, yq, bash and helm 3. Ideally, you should probably have a working minikube cluster to try it out on as well.

The objective is to create a valid service that will install in kubernetes (1.19 or greater). The cluster where this would be installed uses the nginx ingress controller. You may use the format herein, or you can make your own from scratch, but the chart must use the values.yaml format in this repo: the service will be installed on a random port and hostname elsewhere that you have no control over.

When you're done with your helm chart, run the validator.sh script on it. Here are the requirements:
  - You must use the values in the values.yaml as inputs, you can't hardcode the values or the integration tests will fail
  - The healthcheck must function (Using the path from the values.yaml)
  - The service must respond to the name/domain in the values.yaml (the defaults would yield interview-template.local)
  - The service must function without any egress networking access: only incoming connections are allowed for the pod
  - All images used must be publicly available libraries on dockerhub

Our test instance will generate new random values, so you can't hard-code anything.

Once you're done, send a message containing the public repository URL of the repo you created, and our DevSecOps team will check it over and contact you for an interview.

Bonus points for putting in something that will make us laugh.
