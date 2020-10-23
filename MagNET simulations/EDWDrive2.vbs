const PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067

const DOUBLE_SIDED = False
const BUILD_WITH_SYMMETRY = False	' If double sided, build only half the track with symmetry conditions for faster
const runSimulation = True

railMaterial = "Aluminium 6061-T6"
railConductivity = 24940400
magnetMaterial = "N50"

n = 32
r1 = 47.88
r2 = 70
ra = 45 * PI / 180.0
gap = 10
thickness = 50
rail_thickness = 10
rpm = 360
offsetX = 1.0						' Offset of both wheels laterally to test for guidance force (only works when simulating double-sided without symmetry)
start_angle = 0.0 * PI / 180.0

numWheels = 1
spaceBetweenWheels = 30.0

If BUILD_WITH_SYMMETRY Then
    offsetX = 0.0
End If

' Speeds in m/s
speed = 25.0						' Speed of pod
slipSpeed = 30.0					' Slip speed if numSpeedSteps = 1
minSlipSpeed = 10.0					' Starting test slip speed
maxSlipSpeed = 20.0 				' Ending test slip speed
numSpeedSteps = 3					' Number of tests, slip speed is linearly spaces from minSlipSpeed to maxSlipSpeed

solveStepsPerMagnet = 10.0	        ' Number of steps needed for wheel to rotate the angle of one magnet
numSteps = 10*10				    ' Number of simulation steps

If (numSpeedSteps = 1) Then
	minSlipSpeed = slipSpeed
End If

magneticCircumference = 1.04 * r2*PI*2.0 / 1000.0		' Magnetic circumference of wheel (important for accurate slip speeds)

wheelsLength = r2 * 2.0 * numWheels + spaceBetweenWheels * (numWheels - 1)
wheelOffsetY = r2 * 2.0 + spaceBetweenWheels
wheelOffsetAngle = wheelOffsetY / magneticCircumference * PI * 2.0

' Use min rps to calculate max solveStep for max rail length
rps = (speed + minSlipSpeed) / magneticCircumference
solveStep = 1000.0 / (rps * n * solveStepsPerMagnet)

motionLength = speed * (solveStep * numSteps)

' Air boundaries
airRailBoundary = 1.0
airX = r2 * 2.5
airXMin = -50.0
airZ = thickness * 3.0
airYClearance = 40.0
railY = 2*wheelsLength/2.0 + motionLength/2.0 + airYClearance
airY = railY + motionLength/2.0 + airRailBoundary


' Mesh resolutions
airResolution = 10
magnetResolution = 10
aluminiumResolution = 10
magnetFaceResolution = 3
railSurfaceResolution = 3

useHAdaption = False
usePAdaption = False

If NOT getUserMaterialDatabase().isMaterialInDatabase(railMaterial) Then
	Call getUserMaterialDatabase().newMaterial(railMaterial)
	Call getUserMaterialDatabase().setMaterialColor(railMaterial, 192, 192, 192, 255)
	Call getUserMaterialDatabase().setMaterialCategories(railMaterial, Array("Sleeve material", "Shaft material", "Housing material", "Conducting material", "Coil winding material", "Brush material", "Segment material"))
	REDIM ArrayOfValues(0, 2)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 1
	ArrayOfValues(0, 2)= 0
	Call getUserMaterialDatabase().setMagneticPermeability(railMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= railConductivity
	Call getUserMaterialDatabase().setElectricConductivity(railMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 1
	Call getUserMaterialDatabase().setElectricPermittivity(railMaterial, ArrayOfValues, infoLinearIsotropicReal)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 204
	Call getUserMaterialDatabase().setThermalConductivity(railMaterial, ArrayOfValues)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 896
	Call getUserMaterialDatabase().setThermalSpecificHeatCapacity(railMaterial, ArrayOfValues)
	REDIM ArrayOfValues(0, 1)
	ArrayOfValues(0, 0)= 20
	ArrayOfValues(0, 1)= 2707
	Call getUserMaterialDatabase().setMassDensity(railMaterial, ArrayOfValues)
End If

Call newDocument()
Call SetLocale("en-us")
Call getDocument().setDefaultLengthUnit("Millimeters")
Set view = getDocument().getView()

' Air

If BUILD_WITH_SYMMETRY Then
	Call view.newLine(0, -airY, airX, -airY)
	Call view.newLine(airX, -airY, airX, airY)
	Call view.newLine(airX, airY, 0, airY)
	Call view.newLine(0, airY, 0, -airY)
ElseIf NOT DOUBLE_SIDED Then
	Call view.newLine(airXMin, -airY, airX, -airY)
	Call view.newLine(airX, -airY, airX, airY)
	Call view.newLine(airX, airY, airXMin, airY)
	Call view.newLine(airXMin, airY, airXMin, -airY)
Else
	Call view.newLine(-airX, -airY, airX, -airY)
	Call view.newLine(airX, -airY, airX, airY)
	Call view.newLine(airX, airY, -airX, airY)
	Call view.newLine(-airX, airY, -airX, -airY)
End If

Call view.getSlice().moveInALine(-airZ/2.0)
Call view.selectAt(1, 0, infoSetSelection, Array(infoSliceSurface))
Call view.makeComponentInALine(airZ, Array("Outer Air"), "Name=AIR", infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)
Call getDocument().setMaxElementSize("Outer Air", airResolution)
Call view.getSlice().moveInALine(airZ/2.0)
' Call getDocument().getView().setObjectVisible("Outer Air", False)

Call view.selectAll(infoSetSelection, Array(infoSliceLine))
Call view.deleteSelection()

If BUILD_WITH_SYMMETRY Then
	Call getDocument().createBoundaryCondition(Array("Outer Air,Face#6"), "BoundaryCondition#1")
	Call getDocument().setMagneticFieldNormal("BoundaryCondition#1")
End If

' Aluminium

If BUILD_WITH_SYMMETRY Then
	Call view.newLine(0, -railY, rail_thickness/2.0, -railY)
	Call view.newLine(rail_thickness/2.0, -railY, rail_thickness/2.0, railY)
	Call view.newLine(rail_thickness/2.0, railY, 0, railY)
	Call view.newLine(0, railY, 0, -railY)
Else
	Call view.newLine(-rail_thickness/2.0, -railY, rail_thickness/2.0, -railY)
	Call view.newLine(rail_thickness/2.0, -railY, rail_thickness/2.0, railY)
	Call view.newLine(rail_thickness/2.0, railY, -rail_thickness/2.0, railY)
	Call view.newLine(-rail_thickness/2.0, railY, -rail_thickness/2.0, -railY)
End If

Call view.getSlice().moveInALine(-airZ/2.0)
Call view.selectAt(1, 0, infoSetSelection, Array(infoSliceSurface))
Call view.makeComponentInALine(airZ, Array("Aluminium"), "Name=" & railMaterial, infoMakeComponentUnionSurfaces Or infoMakeComponentRemoveVertices)
Call getDocument().setMaxElementSize("Aluminium", aluminiumResolution)
Call view.getSlice().moveInALine(airZ/2.0)

Call view.selectAll(infoSetSelection, Array(infoSliceLine))
Call view.deleteSelection()

Call getDocument().setMaxElementSize("Aluminium,Face#4", railSurfaceResolution)

If DOUBLE_SIDED AND NOT BUILD_WITH_SYMMETRY Then
	Call getDocument().setMaxElementSize("Aluminium,Face#6", railSurfaceResolution)
End If

Call getDocument().makeMotionComponent(Array("Aluminium"))
Call getDocument().setMotionSourceType("Motion#1", infoVelocityDriven)
Call getDocument().setMotionType("Motion#1", infoLinear)
Call getDocument().setMotionLinearDirection("Motion#1", Array(0, 1, 0))
Call getDocument().setMotionPositionAtStartup("Motion#1", -motionLength/2.0)
Call getDocument().setMotionSpeedVsTime("Motion#1", Array(0), Array(speed))

' Magnets

Call view.getSlice().moveInALine(-thickness/2.0)

For wheel = 1 To numWheels
	wheel_y = wheelsLength/2.0 - r2 - (wheel - 1) * wheelOffsetY

	Call view.newCircle((r2 + rail_thickness/2.0 + gap), wheel_y, r1)
	Call view.newCircle((r2 + rail_thickness/2.0 + gap), wheel_y, r2)

	For i = 1 To n
		x_hat = Sin(PI * 2.0 * (i + 0.5) / n + wheelOffsetAngle*(wheel - 1))
		y_hat = Cos(PI * 2.0 * (i + 0.5) / n + wheelOffsetAngle*(wheel - 1))

		Call view.newLine((r2 + rail_thickness/2.0 + gap) + x_hat*r1, y_hat*r1 + wheel_y, (r2 + rail_thickness/2.0 + gap) + x_hat*r2, y_hat*r2 + wheel_y)
	Next

	ReDim Magnets(n - 1)

	For i = 1 To n
		x_hat = Sin(PI * 2.0 * i / n + wheelOffsetAngle*(wheel - 1))
		y_hat = Cos(PI * 2.0 * i / n + wheelOffsetAngle*(wheel - 1))
		mid_r = (r1 + r2) / 2.0

		Call view.selectAt((r2 + rail_thickness/2.0 + gap) + x_hat*mid_r, y_hat*mid_r + wheel_y, infoSetSelection, Array(infoSliceSurface))

		x_hat = Sin(PI * 2.0 * i / n + wheelOffsetAngle*(wheel - 1) - i * ra + PI/2.0)
		y_hat = Cos(PI * 2.0 * i / n + wheelOffsetAngle*(wheel - 1) - i * ra + PI/2.0)

		direction = "[" & x_hat & "," & y_hat & ",0]"
		name = "Magnet" & i & "#" & wheel

		Call view.makeComponentInALine(thickness, Array(name), "Name=N50;Type=Uniform;Direction=" & direction, True)

		Call getDocument().setMaxElementSize(name, magnetResolution)
		Call getDocument().setMaxElementSize(name & ",Face#1", magnetFaceResolution)
		Call getDocument().setMaxElementSize(name & ",Face#2", magnetFaceResolution)
		Call getDocument().setMaxElementSize(name & ",Face#3", magnetFaceResolution)
		Call getDocument().setMaxElementSize(name & ",Face#4", magnetFaceResolution)
		Call getDocument().setMaxElementSize(name & ",Face#5", magnetFaceResolution)
        Call getDocument().setMaxElementSize(name & ",Face#6", magnetFaceResolution)

		Magnets(i - 1) = name
	Next

	Call getDocument().shiftComponent(Magnets, offsetX, 0, 0, 1)

	If DOUBLE_SIDED AND NOT BUILD_WITH_SYMMETRY Then
		Call view.newCircle(-(r2 + rail_thickness/2.0 + gap), wheel_y, r1)
		Call view.newCircle(-(r2 + rail_thickness/2.0 + gap), wheel_y, r2)

		For i = 1 To n
			x_hat = -Sin(PI * 2.0 * (i + 0.5) / n + wheelOffsetAngle*(wheel - 1))
			y_hat = Cos(PI * 2.0 * (i + 0.5) / n + wheelOffsetAngle*(wheel - 1))

			Call view.newLine(-(r2 + rail_thickness/2.0 + gap) + x_hat*r1, y_hat*r1 + wheel_y, -(r2 + rail_thickness/2.0 + gap) + x_hat*r2, y_hat*r2 + wheel_y)
		Next

		ReDim MagnetsB(n - 1)

		For i = 1 To n
			x_hat = -Sin(PI * 2.0 * i / n + wheelOffsetAngle*(wheel - 1))
			y_hat = Cos(PI * 2.0 * i / n + wheelOffsetAngle*(wheel - 1))
			mid_r = (r1 + r2) / 2.0

			Call view.selectAt(-(r2 + rail_thickness/2.0 + gap) + x_hat*mid_r, y_hat*mid_r + wheel_y, infoSetSelection, Array(infoSliceSurface))

			x_hat = -Sin(PI * 2.0 * i / n + wheelOffsetAngle*(wheel - 1) - i * ra - PI/2.0)
			y_hat = Cos(PI * 2.0 * i / n + wheelOffsetAngle*(wheel - 1) - i * ra - PI/2.0)

			direction = "[" & x_hat & "," & y_hat & ",0]"
			name = "MagnetB" & i & "#" & wheel

			Call view.makeComponentInALine(thickness, Array(name), "Name=N50;Type=Uniform;Direction=" & direction, True)

			Call getDocument().setMaxElementSize(name, magnetResolution)
			Call getDocument().setMaxElementSize(name & ",Face#1", magnetFaceResolution)
			Call getDocument().setMaxElementSize(name & ",Face#2", magnetFaceResolution)
			Call getDocument().setMaxElementSize(name & ",Face#3", magnetFaceResolution)
			Call getDocument().setMaxElementSize(name & ",Face#4", magnetFaceResolution)
			Call getDocument().setMaxElementSize(name & ",Face#5", magnetFaceResolution)
			Call getDocument().setMaxElementSize(name & ",Face#6", magnetFaceResolution)

			MagnetsB(i - 1) = name
		Next

		Call getDocument().shiftComponent(MagnetsB, offsetX, 0, 0, 1)
	End If

	Call view.selectAll(infoSetSelection, Array(infoSliceLine, infoSliceArc))
	Call view.deleteSelection()

	motionComponent = getDocument().makeMotionComponent(Magnets)
    Call getDocument().setMotionSourceType(motionComponent, infoVelocityDriven)
    Call getDocument().setMotionRotaryCenter(motionComponent, Array((r2 + rail_thickness/2.0 + gap) + offsetX, wheel_y, 0))
    Call getDocument().setMotionRotaryAxis(motionComponent, Array(0, 0, 1))
    Call getDocument().setMotionPositionAtStartup(motionComponent, start_angle)
	Call getDocument().setParameter(motionComponent, "SpeedVsTime", "[0%ms, -(%rotSpeed)]", infoArrayParameter)

	If DOUBLE_SIDED AND NOT BUILD_WITH_SYMMETRY Then
		Call getDocument().shiftComponent(MagnetsB, offsetX, 0, 0, 1)

		motionComponent = getDocument().makeMotionComponent(MagnetsB)
		Call getDocument().setMotionSourceType(motionComponent, infoVelocityDriven)
		Call getDocument().setMotionRotaryCenter(motionComponent, Array(-(r2 + rail_thickness/2.0 + gap) + offsetX, wheel_y, 0))
		Call getDocument().setMotionRotaryAxis(motionComponent, Array(0, 0, 1))
		Call getDocument().setMotionPositionAtStartup(motionComponent, -start_angle)
		Call getDocument().setParameter(motionComponent, "SpeedVsTime", "[0%ms, %rotSpeed]", infoArrayParameter)
	End If
Next

Call view.getSlice().moveInALine(thickness/2.0)

Call getDocument().setTimeStepMethod(infoFixedIntervalTimeStep)
' Call getDocument().setFixedIntervalTimeSteps(0, solveStep*numSteps, solveStep)
' Call getDocument().deleteTimeStepMaximumDelta()
' Call getDocument().setAdaptiveTimeSteps(0, solveStep*numSteps, solveStep, solveStep * 4)
' Call getDocument().setTimeAdaptionTolerance(0.03)

Call getDocument().useHAdaption(useHAdaption)
Call getDocument().usePAdaption(usePAdaption)

If numSpeedSteps = 1 Then
	rps = (speed + slipSpeed) / (magneticCircumference)
    text1 = text1 & rps*2.0*PI & "%rad"
Else
    For i = 1 to numSpeedSteps
        slipSpeed = (i - 1) * ((maxSlipSpeed - minSlipSpeed) / (numSpeedSteps - 1)) + minSlipSpeed
        rps = (speed + slipSpeed) / (magneticCircumference)
        text1 = text1 & rps*2.0*PI & "%rad"
        If i <> numSpeedSteps Then
            text1 = text1 & ", "
        End If
    Next
End If

Call getDocument().setParameter("", "rotSpeed", text1, infoNumberParameter)
Call getDocument().setParameter("", "TimeSteps", "[0%ms, (1000.0/((%rotSpeed/(2.0*%Pi))*" & n & "*" & solveStepsPerMagnet & "))%ms, " & "(1000.0/((%rotSpeed/(2.0*%Pi))*" & n & "*" & solveStepsPerMagnet & ")*" & numSteps & ")%ms]", infoArrayParameter)

' Scale view to fit

Call getDocument().getView().setScaledToFit(True)

if runSimulation Then
	Call getDocument().solveTransient2DWithMotion()
End If
