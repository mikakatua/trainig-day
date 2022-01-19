Build and deploy instructions

```
docker build -t mikakatua/app2 .
docker push mikakatua/app2
kubectl apply -f k8s
POD=$(kubectl get po -l app=app2 -o=jsonpath='{.items[0].metadata.name}')
kubectl cp index.php $POD:/var/www/html -c app2
```

Test
```
kubectl exec deploy/app2 -c app2 -- curl -s localhost
```
