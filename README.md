# Capstone for the [Udacity DevOps Engineer Nanodegree](https://www.udacity.com/course/cloud-dev-ops-nanodegree--nd9991)

### Goal
You will develop a CI/CD pipeline for micro services applications with either blue/green deployment or rolling deployment.


### Requirements
  - App container built, linted, and pushed to a registory
  - Jenkins server able to perform a blue/green or rolling deployment
  - Kubernetes cluster to host the app


---

### Build the environment
* Generate ssh key: `make generate_jenkins_ssh_key`
* Build Jenkins: `make build_stack`
* Get the Jenkins temp password at `/var/lib/jenkins/secrets/initialAdminPassword`: `make ssh_jenkins`
* Log into Jenkins and set the admin password: `make jenkins_url`
* Select install suggested plugins
* Create a user
* Install the Blue Ocean plugin and open Blue Ocean
* Create a Github Personal Access Token with [these permissions](https://github.com/settings/tokens/new?scopes=repo,read:user,user:email,write:repo_hook)
* Click Create a new Pipeline, select Github, enter access token, select the organization, select the capstone repo, click Create Pipeline
```