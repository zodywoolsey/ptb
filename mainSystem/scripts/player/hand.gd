extends XRController3D

@onready var grabArea : Area3D = $grabArea
@onready var grabConstraint : Generic6DOFJoint3D = $grabConstraint
@onready var handRay : RayCast3D = $RayCast3D
var grabAreaBodies : Array = []
var rayBody : RigidBody3D

func _ready():
	grabArea.connect("body_entered", grabBodyEntered)
	grabArea.connect("body_exited", grabBodyExited)
	connect("button_pressed",buttonPressed)
	connect("button_released",buttonReleased)

func _process(delta):
	pass

func _input(event):
	pass

func grabBodyEntered(body):
	if body.has_meta("grabbable"):
		var bodyMeta = body.get_meta("grabbable")
		if bodyMeta != 0:
			grabAreaBodies.push_back(body)

func grabBodyExited(body):
	var tmp = grabAreaBodies.find(body)
	if tmp != -1:
		grabAreaBodies.pop_at(tmp)

func buttonPressed(name):
	if name == "grip_click":
		if grabAreaBodies.size() > 0:
			grab(grabAreaBodies[0])
		elif handRay.is_colliding():
			var rayCollided = handRay.get_collider()
			if rayCollided.has_meta("grabbable"):
				grab(rayCollided,true)
	elif name == "trigger_click":
		handRay.enabled = true
	print(name)
	
func buttonReleased(name):
	if name == "grip_click" and !grabConstraint.node_b.is_empty():
		if get_node(grabConstraint.node_b).get_class() == "RigidBody3D":
			get_node(grabConstraint.node_b).freeze = false
		grabConstraint.position = Vector3(0,0,0)
		grabConstraint.node_b = ""
	if name == "trigger_click":
		handRay.enabled = false
		rayBody = null

func grab(node, laser:bool=false):
	var tmpgrab = node.get_meta("grabbable")
	print(tmpgrab)
	if tmpgrab == 1:
		if laser:
			grabConstraint.global_position = node.global_position
		grabConstraint.node_b = node.get_path()
	
	#node.freeze = true