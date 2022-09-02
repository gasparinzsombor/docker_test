docker network create el-kube-net

docker build -t docker_test:latest .

docker run --rm -d \
  -h db \
  -e POSTGRES_DB=el_kube_prod \
  -e POSTGRES_PASSWORD=korte \
  -e POSTGRES_USER=alma \
  -p 5432 \
  --name db \
  --network el-kube-net \
  postgres:9.6

kubectl create -f k8s/pvc.yaml
kubectl create -f k8s/db.yaml
kubectl create -f k8s/db-svc.yaml
kubectl create -f k8s/docker-test-private-svc.yaml
kubectl create -f k8s/docker-test-public-svc.yaml
kubectl create -f k8s/docker-test.yaml

minikube service docker-test-public

docker run -it -e DATABASE_URL=ecto://alma:korte@db/el_kube_prod -e SECRET_KEY_BASE=R8hgiR5Cew6GeLpdfghjdfghjkghjkghytgzEEw94b9sz34WIKk8ZzTab2xihmI65kPEWyqYyO0 --network el-kube-net --name phoenix -h phoenix -p 4000:4000 docker_test:latest