KIND_INSTANCE=k8s-flyte-playground

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

.PHONY: helm_init
helm_init:
	helm repo add flyte https://flyteorg.github.io/flyte
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add minio https://charts.min.io/
	helm repo update
	
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

.PHONY: port_forward_all
port_forward_all: k8s_connect
	kubectl port-forward svc/minio -n minio 9000 & 
	kubectl port-forward svc/flyte-flyte-binary-grpc -n flyte 8089 & 
	kubectl port-forward svc/flyte-flyte-binary-http -n flyte 8088 & 


# loads the docker containers into the kind environments
#.PHONY: k8s_side_load
#k8s_side_load: k8s_connect
#	kind load docker-image example-app --name $(KIND_INSTANCE)

#.PHONY: build_docker_image
#build_docker_image:
#	docker build -t fib-app:latest .
