extends Node

var services: Dictionary[String, Node] = {}

func register(service_name: String, service: Node):
	services[service_name] = service

func unregister(service_name: String):
	if not services.has(service_name):
		printerr(service_name, " not registered to service locator")
		return
	
	services.erase(service_name)

func service_exists(service_name: String) -> bool:
	if services.has(service_name):
		return true
	
	return false

func get_service(service_name: String) -> Node:
	if services.has(service_name):
		return services[service_name]
	
	printerr(service_name, " not registered to service locator")
	return null
