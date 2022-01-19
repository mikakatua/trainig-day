Build and deploy instructions

```
docker build -t mikakatua/app1 .
docker push mikakatua/app1
kubectl apply -f k8s
```

Test
```
kubectl exec deploy/app1 -- wget -qO- localhost
```
