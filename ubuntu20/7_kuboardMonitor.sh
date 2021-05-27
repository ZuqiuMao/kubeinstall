echo ---------------------------------
echo 7 - kuboard monitor install 
echo ---------------------------------

#install kuboard
kubectl apply -f https://kuboard.cn/install-script/kuboard.yaml
# admin token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kuboard-user | awk '{print $1}')

echo user guide:
echo url: http://ip:32567
echo kubectl get nodes -o wide
echo kubectl get pods -A -o wide
