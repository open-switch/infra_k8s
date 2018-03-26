aptly_exec:
	@kubectl -n prod exec -it "$$(kubectl get pods -n prod -l 'app=aptly' -o jsonpath='{.items[0].metadata.name}')" -- bash --login

aptly_cp:
	@kubectl -n prod cp $(FILE) "$$(kubectl get pods -n prod -l 'app=aptly' -o jsonpath='{.items[0].metadata.name}')":/aptly/private/

token:
	@kubectl -n kube-system describe secret "$$(kubectl -n kube-system get secret | grep $$USER | awk '{print $$1}')" | grep token: | awk '{print $$2}'

dashboard:
	kubectl proxy

