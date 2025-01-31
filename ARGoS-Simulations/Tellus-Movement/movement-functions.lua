function stopMovement()
	robot.joints.bl_arm_wheel.set_target(0)
	robot.joints.ml_arm_wheel.set_target(0)
	robot.joints.fl_arm_wheel.set_target(0)
	robot.joints.br_arm_wheel.set_target(0)
	robot.joints.mr_arm_wheel.set_target(0)
	robot.joints.fr_arm_wheel.set_target(0)
end

function driveForward(velocity)
	robot.joints.bl_arm_wheel.set_target(velocity)
	robot.joints.ml_arm_wheel.set_target(0-velocity)
	robot.joints.fl_arm_wheel.set_target(0-velocity)
	
	robot.joints.br_arm_wheel.set_target(0-velocity)
	robot.joints.mr_arm_wheel.set_target(velocity)
	robot.joints.fr_arm_wheel.set_target(0-velocity)
end

function turnLeft(velocity)

	--reverse left side
	robot.joints.bl_arm_wheel.set_target(velocity)
	robot.joints.ml_arm_wheel.set_target(velocity/2)
	robot.joints.fl_arm_wheel.set_target(velocity)

	--forward right side
	robot.joints.br_arm_wheel.set_target(0-velocity)
	robot.joints.mr_arm_wheel.set_target(velocity/2)
	robot.joints.fr_arm_wheel.set_target(0-velocity)
	
end

function turnRight(velocity)
	--forward left side
	robot.joints.bl_arm_wheel.set_target(0-velocity)
	robot.joints.ml_arm_wheel.set_target(0-velocity/2)
	robot.joints.fl_arm_wheel.set_target(0-velocity)

	--reverse right side
	robot.joints.br_arm_wheel.set_target(velocity)
	robot.joints.mr_arm_wheel.set_target(0-velocity/2)
	robot.joints.fr_arm_wheel.set_target(velocity)
end

function reverse(velocity)
	robot.joints.bl_arm_wheel.set_target(0-velocity)
	robot.joints.ml_arm_wheel.set_target(velocity)
	robot.joints.fl_arm_wheel.set_target(velocity)
	robot.joints.br_arm_wheel.set_target(velocity)
	robot.joints.mr_arm_wheel.set_target(0-velocity)
	robot.joints.fr_arm_wheel.set_target(velocity)
end

function getYaw()
	local w = robot.positioning.orientation.w
	local x = robot.positioning.orientation.x
	local y = robot.positioning.orientation.y
	local z = robot.positioning.orientation.z
	local t3 = 2*(w*z+x*y)
	local t4 = 1 - 2*(y*y+z*z)

	local yaw = math.atan(t3, t4)*(180/math.pi)
	if yaw<0 then
		yaw = yaw + 360
	end
	yaw = yaw * math.pi/180
	--convert quarternion to z rotation
	return yaw
end

function driveTo(x,y, forward_velocity)
	local isTurning
	--get x and y of robot
	local current_x= robot.positioning.position.x
	local current_y= robot.positioning.position.y
	--create cartesian trajectory vector table


	local traj_vector_cart = {x - current_x, y - current_y}
	
	--calculate magnitude of trajectory
	local sum_of_squares=math.pow((x - current_x),2)+math.pow((y - current_y),2)

	local traj_magnitude=math.sqrt(sum_of_squares)	
	--convert quarternion to z rotation
	local current_angle = getYaw()

	--create cartesian face vector 

	local face_vector_cart = {math.cos(current_angle), math.sin(current_angle)}
	
	--Cross product of trajectory vector with face direction vector
	--Shortcut for 2d vectors since theres no cross product function.
	--T x F <-- Order is important
	local cross_p = (traj_vector_cart[1]*face_vector_cart[2])-(face_vector_cart[1]*traj_vector_cart[2])
	
	--Angle between them is inverse cosine of the dot product T and F divided by the manitude of Trajectory vector.
	--acos(F*T/|T|)
	--This angle will always be between 0-180
	local dot_p = face_vector_cart[1]*traj_vector_cart[1] + face_vector_cart[2]*traj_vector_cart[2]
	local a = math.deg((math.acos(dot_p/traj_magnitude)))

	--log("Angle between :" .. a)
	--log("Cross Product:" .. cross_p)
	--log("Face Angle " .. current_angle)
	--If the result is negative, Turn Left. Otherwise turn Right. We can use the angle to determine how much we need to turn.
	local speed_ratio = 10 
	
	if cross_p < -0.02 then
		turnLeft(speed_ratio/2)
		isTurning = true
	
	elseif cross_p > 0.02 then 
		turnRight(speed_ratio/2)
		isTurning = false
	else
		if a < 0.2 then
				driveForward(forward_velocity)		
		end
	end
	return isTurning
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
  end
