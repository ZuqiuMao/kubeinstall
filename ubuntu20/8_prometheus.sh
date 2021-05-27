echo ---------------------------------
echo 8 - prometheus
echo ---------------------------------

git clone https://github.com/prometheus-operator/kube-prometheus.git
cd kube-prometheus

# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
kubectl create -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f manifests/

# allow schedule on Master Node
#kubectl taint nodes --all node-role.kubernetes.io/master-

# pull kube-state-metrics
#docker pulll quay.io/coreos/kube-state-metrics:v2.0.0-beta
#sudo docker tag quay.io/coreos/kube-state-metrics:v2.0.0-beta k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.0.0


#expose port to external access
