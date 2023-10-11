KIND_INSTANCE=k8s-flyte-playground
IMAGE_NAME=weird-workflow
IMAGE_VERSION=1.0.0

# creates a K8s instance
.PHONY: k8s_new
k8s_new:
	kind create cluster --config ./kind/kind.yaml --name $(KIND_INSTANCE)

# deletes a k8s instance
.PHONY: k8s_drop
k8s_drop:
	kind delete cluster --name $(KIND_INSTANCE)

# sets KUBECONFIG for the K8s instance
.PHONY: k8s_connect
k8s_connect:
	kind export kubeconfig --name $(KIND_INSTANCE)

# adds and updates the required helm charts
.PHONY: helm_init
helm_init:
	helm repo add flyte https://flyteorg.github.io/flyte
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add minio https://charts.min.io/
	helm repo update
	
# installs a postgres toy instance, minio and flyte
.PHONY: install_infra
install_infra: k8s_connect
	kubectl apply -f ./k8s/postgres/postgres-toy.yaml
	# install minio as we'd like an S3 like backend
	# configure with 1 replicas and a small amount of memory
	helm install --namespace minio --create-namespace \
		--values ./k8s/minio/values.yaml \
		minio minio/minio
	# install flyte
	helm install --namespace flyte --create-namespace \
		--values ./k8s/flyte/values.yaml \
		flyte flyte/flyte-binary

# port forward to the K8s cluster
.PHONY: port_forward_all
port_forward_all: k8s_connect
	kubectl port-forward svc/minio -n minio 9000 & 
	kubectl port-forward svc/flyte-flyte-binary-grpc -n flyte 8089 & 
	kubectl port-forward svc/flyte-flyte-binary-http -n flyte 8088 & 

# loads the docker containers into the kind environments
.PHONY: k8s_side_load
k8s_side_load: k8s_connect
	kind load docker-image ${IMAGE_NAME} --name $(KIND_INSTANCE)

# builds the docke image locally so that we can deploy it
.PHONY: build_docker_image
build_docker_image:
	docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} .

# installs the workflow
.PHONY: deploy
deploy:
	poetry run pyflyte --pkgs src --verbose package --output ${IMAGE_NAME}.tgz -f --image localhost:30000/${IMAGE_NAME}:${IMAGE_VERSION}
	flytectl register files --project flytesnacks --domain development --archive ${IMAGE_NAME}.tgz  --version ${IMAGE_VERSION}

# runs the deployed workflow
.PHONY: run
run:
	pyflyte run --remote src/example.py weird_workflow
