echo ---------------------------------
echo 6 - calico network install 
echo ---------------------------------

# install calico pod with yaml deployment
sudo curl -o calico.yaml https://docs.projectcalico.org/v3.11/manifests/calico.yaml
kubectl apply -f calico.yaml