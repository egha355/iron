!> \file
!> \author Chris Bradley
!> \brief This module handles all problem routines.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand, the University of Oxford, Oxford, United
!> Kingdom and King's College, London, United Kingdom. Portions created
!> by the University of Auckland, the University of Oxford and King's
!> College, London are Copyright (C) 2007-2010 by the University of
!> Auckland, the University of Oxford and King's College, London.
!> All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> This module handles all problem routines.
MODULE PROBLEM_ROUTINES

  USE BaseRoutines
  USE BIOELECTRIC_ROUTINES
  USE CLASSICAL_FIELD_ROUTINES
  USE CONTROL_LOOP_ROUTINES
  USE ControlLoopAccessRoutines
  USE DistributedMatrixVector
  USE ELASTICITY_ROUTINES
  USE EquationsRoutines
  USE EquationsSetConstants
  USE EQUATIONS_SET_ROUTINES
  USE FIELD_ROUTINES
  USE FIELD_IO_ROUTINES
  USE FINITE_ELASTICITY_ROUTINES
  USE FittingRoutines
  USE FLUID_MECHANICS_ROUTINES
  USE INPUT_OUTPUT
  USE INTERFACE_CONDITIONS_CONSTANTS
  USE INTERFACE_CONDITIONS_ROUTINES
  USE INTERFACE_ROUTINES
  USE ISO_VARYING_STRING
  USE Kinds
  USE MULTI_PHYSICS_ROUTINES
  USE PROBLEM_CONSTANTS
  USE ProblemAccessRoutines
  USE REACTION_DIFFUSION_EQUATION_ROUTINES
  USE SOLVER_ROUTINES
  USE SolverAccessRoutines
  USE SOLVER_MATRICES_ROUTINES
  USE Strings
  USE Timer
  USE Types

#include "macros.h"  

  IMPLICIT NONE

  PRIVATE

  !Module parameters

  !Module types

  !Module variables

  !Interfaces

  PUBLIC PROBLEMS_INITIALISE,PROBLEMS_FINALISE
  
  PUBLIC PROBLEM_CELLML_EQUATIONS_CREATE_START,PROBLEM_CELLML_EQUATIONS_CREATE_FINISH
  
  PUBLIC PROBLEM_CREATE_START,PROBLEM_CREATE_FINISH,PROBLEM_DESTROY
  
  PUBLIC Problem_SpecificationGet,Problem_SpecificationSizeGet
  
  PUBLIC PROBLEM_CONTROL_LOOP_CREATE_START,PROBLEM_CONTROL_LOOP_CREATE_FINISH
  
  PUBLIC PROBLEM_CONTROL_LOOP_DESTROY
  
  PUBLIC Problem_SolverDAECellMLRHSEvaluate
  
  PUBLIC Problem_SolverEquationsBoundaryConditionsAnalytic

  PUBLIC PROBLEM_SOLVER_EQUATIONS_CREATE_START,PROBLEM_SOLVER_EQUATIONS_CREATE_FINISH
  
  PUBLIC PROBLEM_SOLVER_EQUATIONS_DESTROY
  
  PUBLIC PROBLEM_SOLVER_JACOBIAN_EVALUATE,PROBLEM_SOLVER_RESIDUAL_EVALUATE
  
  PUBLIC Problem_SolverNonlinearMonitor

  PUBLIC Problem_SolverOptimiserMonitor
  
  PUBLIC PROBLEM_SOLVE
  
  PUBLIC PROBLEM_SOLVERS_CREATE_START,PROBLEM_SOLVERS_CREATE_FINISH
  
  PUBLIC PROBLEM_SOLVERS_DESTROY
  
CONTAINS

  !
  !================================================================================================================================
  !

  !>Finish the creation of the CellML equations for the problem solver. \see OpenCMISS::cmfe_Problem_SolverCellMLEquationsCreateFinish
  SUBROUTINE PROBLEM_CELLML_EQUATIONS_CREATE_FINISH(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to finish the CellML equations for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO

    ENTERS("PROBLEM_CELLML_EQUATIONS_CREATE_FINISH",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN      
      !Initialise the problem setup information
      CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
      PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_CELLML_EQUATIONS_TYPE
      PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_FINISH_ACTION
      !Finish problem specific startup
      CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
      !Finalise the problem setup information
      CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
      
    EXITS("PROBLEM_CELLML_EQUATIONS_CREATE_FINISH")
    RETURN
999 ERRORSEXITS("PROBLEM_CELLML_EQUATIONS_CREATE_FINISH",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_CELLML_EQUATIONS_CREATE_FINISH
  
  !
  !================================================================================================================================
  !

  !>Start the creation of CellML equations for a problem solver. \see OpenCMISS::cmfe_Problem_SolverCellMLEquationsCreateStart
  SUBROUTINE PROBLEM_CELLML_EQUATIONS_CREATE_START(PROBLEM,err,error,*)

    !Argument variablesg
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to start the creation of the CellML equations for.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO

    ENTERS("PROBLEM_CELLML_EQUATIONS_CREATE_START",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      !Initialise the problem setup information
      CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
      PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_CELLML_EQUATIONS_TYPE
      PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_START_ACTION
      !Start the problem specific control setup
      CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
      !Finalise the problem setup information
      CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_CELLML_EQUATIONS_CREATE_START")
    RETURN
999 ERRORSEXITS("PROBLEM_CELLML_EQUATIONS_CREATE_START",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_CELLML_EQUATIONS_CREATE_START

  !
  !================================================================================================================================
  !

  !>Solves CellML equations for a problem.
  SUBROUTINE Problem_CellMLEquationsSolve(cellMLEquations,err,error,*)

   !Argument variables
    TYPE(CELLML_EQUATIONS_TYPE), POINTER :: cellMLEquations !<A pointer to the CellML equations to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    REAL(DP) :: currentTime,timeIncrement
    TYPE(CONTROL_LOOP_TYPE), POINTER :: controlLoop
    TYPE(SOLVER_TYPE), POINTER :: solver
    TYPE(VARYING_STRING) :: localError
    
    ENTERS("Problem_CellMLEquationsSolve",err,error,*999)
    
    IF(.NOT.ASSOCIATED(cellMLEquations)) CALL FlagError("CellML equations is not associated.",err,error,*999)
    IF(.NOT.cellMLEquations%CELLML_EQUATIONS_FINISHED) CALL FlagError("CellML equations have not been finished.",err,error,*999)

    NULLIFY(solver)
    CALL CellMLEquations_SolverGet(cellMLEquations,solver,err,error,*999)
    IF(solver%outputType>=SOLVER_PROGRESS_OUTPUT) THEN
      CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
      CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"CellML equations solve: ",solver%label,err,error,*999)
    ENDIF

    SELECT CASE(cellMLEquations%timeDependence)
    CASE(CELLML_EQUATIONS_STATIC)
      !Do nothing
    CASE(CELLML_EQUATIONS_QUASISTATIC,CELLML_EQUATIONS_DYNAMIC)
      NULLIFY(controlLoop)
      CALL Solver_ControlLoopGet(solver,controlLoop,err,error,*999)
      CALL ControlLoop_CurrentTimesGet(controlLoop,currentTime,timeIncrement,err,error,*999)
      CALL CellMLEquations_TimeSet(cellMLEquations,currentTime,err,error,*999)
    CASE DEFAULT
      localError="The CellML equations time dependence type of "// &
        & TRIM(NumberToVString(cellMLEquations%timeDependence,"*",err,error))//" is invalid."
      CALL FlagError(localError,err,error,*999)
    END SELECT
    
    CALL Solver_Solve(solver,err,error,*999)
      
    EXITS("Problem_CellMLEquationsSolve")
    RETURN
999 ERRORSEXITS("Problem_CellMLEquationsSolve",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_CellMLEquationsSolve

  !
  !================================================================================================================================
  !

  !>Solves CellML equations for a problem.
  SUBROUTINE Problem_SolverDAECellMLRHSEvaluate(cellML,time,dofIdx,stateData,rateData,err,error,*)

   !Argument variables
    TYPE(CELLML_TYPE), POINTER :: cellML !<A pointer to the CellML to evaluate
    REAL(DP), INTENT(IN) :: time !<The time to evaluate the CellML model at
    INTEGER(INTG), INTENT(IN) :: dofIdx !<The index of the DOF to evaluate
    REAL(DP), POINTER :: stateData(:) !<The states data to evaluate the model at
    REAL(DP), POINTER :: rateData(:) !<On exit, the evaluated rates
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: dofOrderType,intermediateDataOffset,maxNumberOfIntermediates,maxNumberOfParameters,maxNumberOfStates, &
      modelIdx,parameterDataOffset
    INTEGER(INTG), POINTER :: modelsData(:)
    REAL(DP), POINTER :: intermediateData(:),parameterData(:)
    TYPE(CELLML_MODEL_TYPE), POINTER :: model
    TYPE(FIELD_TYPE), POINTER :: intermediateField,modelsField,parametersField
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: modelsVariable
    
    ENTERS("Problem_SolverDAECellMLRHSEvaluate",err,error,*999)
    
    IF(ASSOCIATED(cellML)) THEN
      maxNumberOfStates=cellML%MAXIMUM_NUMBER_OF_STATE
      maxNumberOfIntermediates=cellML%MAXIMUM_NUMBER_OF_INTERMEDIATE
      maxNumberOfParameters=cellML%MAXIMUM_NUMBER_OF_PARAMETERS
      !Make sure CellML fields have been updated to the current value of any mapped fields
      IF(ASSOCIATED(cellML%MODELS_FIELD)) THEN
        modelsField=>cellML%MODELS_FIELD%MODELS_FIELD
        IF(ASSOCIATED(modelsField)) THEN
          NULLIFY(modelsVariable)
          CALL Field_VariableGet(modelsField,FIELD_U_VARIABLE_TYPE,modelsVariable,err,error,*999)
          CALL Field_DOFOrderTypeGet(modelsField,FIELD_U_VARIABLE_TYPE,dofOrderType,err,error,*999)
          CALL Field_ParameterSetDataGet(modelsField,FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,modelsData,err,error,*999)
          modelIdx=modelsData(dofIdx)
          model=>cellML%models(modelIdx)%ptr
          IF(ASSOCIATED(model)) THEN
            IF(dofOrderType==FIELD_SEPARATED_COMPONENT_DOF_ORDER) THEN
              parameterDataOffset=modelsVariable%TOTAL_NUMBER_OF_DOFS
              intermediateDataOffset=modelsVariable%TOTAL_NUMBER_OF_DOFS
            ELSE
              parameterDataOffset=maxNumberOfParameters
              intermediateDataOffset=maxNumberOfIntermediates
            ENDIF
            NULLIFY(parameterData)
            !Get the parameters information if this environment has any.
            IF(ASSOCIATED(cellML%PARAMETERS_FIELD)) THEN
              parametersField=>cellML%PARAMETERS_FIELD%PARAMETERS_FIELD
              IF(ASSOCIATED(parametersField)) THEN
                CALL Field_ParameterSetDataGet(parametersField,FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,parameterData, &
                  & err,error,*999)
              ENDIF
            ENDIF
            !Get the intermediate information if this environment has any.
            NULLIFY(intermediateData)
            IF(ASSOCIATED(cellML%INTERMEDIATE_FIELD)) THEN
              intermediateField=>cellml%INTERMEDIATE_FIELD%INTERMEDIATE_FIELD
              IF(ASSOCIATED(intermediateField)) THEN
                CALL Field_ParameterSetDataGet(intermediateField,FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,intermediateData, &
                  & err,error,*999)
              ENDIF
            ENDIF!associated intermediate
            
            !Evaluate the CellML RHS
            CALL Solver_DAECellMLRHSEvaluate(model,time,1,1,stateData,dofIdx,parameterDataOffset,parameterData,dofIdx, &
              intermediateDataOffset,intermediateData,1,1,rateData,err,error,*999)
            
          ELSE
            CALL FlagError("Model is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Models field not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("CellML models field is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("CellML is not associated.",err,error,*999)
    ENDIF
    
    EXITS("Problem_SolverDAECellMLRHSEvaluate")
    RETURN
999 ERRORSEXITS("Problem_SolverDAECellMLRHSEvaluate",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SolverDAECellMLRHSEvaluate

  !
  !================================================================================================================================
  !

  !>Solves a problem control loop.
  RECURSIVE SUBROUTINE PROBLEM_CONTROL_LOOP_SOLVE(CONTROL_LOOP,err,error,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: iteration_idx,loop_idx,solver_idx
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP2
    TYPE(CONTROL_LOOP_FIXED_TYPE), POINTER :: FIXED_LOOP
    TYPE(CONTROL_LOOP_SIMPLE_TYPE), POINTER :: SIMPLE_LOOP
    TYPE(CONTROL_LOOP_TIME_TYPE), POINTER :: TIME_LOOP
    TYPE(CONTROL_LOOP_WHILE_TYPE), POINTER :: WHILE_LOOP
    TYPE(CONTROL_LOOP_LOAD_INCREMENT_TYPE), POINTER :: LOAD_INCREMENT_LOOP
    TYPE(SOLVER_TYPE), POINTER :: SOLVER
    TYPE(SOLVERS_TYPE), POINTER :: SOLVERS
    TYPE(VARYING_STRING) :: localError
    
    ENTERS("PROBLEM_CONTROL_LOOP_SOLVE",err,error,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(CONTROL_LOOP%CONTROL_LOOP_FINISHED) THEN
        !Solve this control loop
        IF(CONTROL_LOOP%outputType>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
          CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
          CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Control loop: ",CONTROL_LOOP%LABEL,err,error,*999)
          CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Control loop level = ",CONTROL_LOOP%CONTROL_LOOP_LEVEL,err,error,*999)
          CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Sub loop index     = ",CONTROL_LOOP%SUB_LOOP_INDEX,err,error,*999)
        ENDIF
        IF(diagnostics1) THEN
          CALL WriteString(DIAGNOSTIC_OUTPUT_TYPE,"",err,error,*999)
          CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"Control loop: ",CONTROL_LOOP%LABEL,err,error,*999)
          CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  Control loop level = ",CONTROL_LOOP%CONTROL_LOOP_LEVEL,err,error,*999)
          CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  Sub loop index     = ",CONTROL_LOOP%SUB_LOOP_INDEX,err,error,*999)
        ENDIF
        SELECT CASE(CONTROL_LOOP%LOOP_TYPE)
        CASE(PROBLEM_CONTROL_SIMPLE_TYPE)
          SIMPLE_LOOP=>CONTROL_LOOP%SIMPLE_LOOP
          IF(ASSOCIATED(SIMPLE_LOOP)) THEN
            IF(CONTROL_LOOP%outputType>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
              CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
              CALL WriteString(GENERAL_OUTPUT_TYPE,"Simple control loop: ",err,error,*999)
            ENDIF
            IF(diagnostics1) THEN
              CALL WriteString(DIAGNOSTIC_OUTPUT_TYPE,"",err,error,*999)
              CALL WriteString(DIAGNOSTIC_OUTPUT_TYPE,"Simple control loop: ",err,error,*999)
            ENDIF
            CALL PROBLEM_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*999)
            IF(CONTROL_LOOP%NUMBER_OF_SUB_LOOPS==0) THEN
              !If there are no sub loops then solve.
              SOLVERS=>CONTROL_LOOP%SOLVERS
              IF(ASSOCIATED(SOLVERS)) THEN
                DO solver_idx=1,SOLVERS%NUMBER_OF_SOLVERS
                  SOLVER=>SOLVERS%SOLVERS(solver_idx)%PTR

                  CALL Problem_SolverSolve(solver,err,error,*999)

                ENDDO !solver_idx
              ELSE
                CALL FlagError("Control loop solvers is not associated.",err,error,*999)
              ENDIF
            ELSE
              !If there are sub loops the recursively solve those control loops
              DO loop_idx=1,CONTROL_LOOP%NUMBER_OF_SUB_LOOPS
                CONTROL_LOOP2=>CONTROL_LOOP%SUB_LOOPS(loop_idx)%PTR
                CALL PROBLEM_CONTROL_LOOP_SOLVE(CONTROL_LOOP2,err,error,*999)
              ENDDO !loop_idx
            ENDIF
            CALL PROBLEM_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
          ELSE
            CALL FlagError("Control loop simple loop is not associated.",err,error,*999)
          ENDIF
        CASE(PROBLEM_CONTROL_FIXED_LOOP_TYPE)
          FIXED_LOOP=>CONTROL_LOOP%FIXED_LOOP
          IF(ASSOCIATED(FIXED_LOOP)) THEN
            DO iteration_idx=FIXED_LOOP%START_ITERATION,FIXED_LOOP%STOP_ITERATION,FIXED_LOOP%ITERATION_INCREMENT
              IF(CONTROL_LOOP%outputType>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
                CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Fixed control loop iteration: ",iteration_idx,err,error,*999)
              ENDIF
              IF(diagnostics1) THEN
                CALL WriteString(DIAGNOSTIC_OUTPUT_TYPE,"",err,error,*999)
                CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"Fixed control loop iteration: ",iteration_idx,err,error,*999)
              ENDIF
              FIXED_LOOP%ITERATION_NUMBER=iteration_idx
              CALL PROBLEM_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*999)
              IF(CONTROL_LOOP%NUMBER_OF_SUB_LOOPS==0) THEN
                !If there are no sub loops then solve
                SOLVERS=>CONTROL_LOOP%SOLVERS
                IF(ASSOCIATED(SOLVERS)) THEN
                  DO solver_idx=1,SOLVERS%NUMBER_OF_SOLVERS
                    SOLVER=>SOLVERS%SOLVERS(solver_idx)%PTR
                    
                    CALL Problem_SolverSolve(solver,err,error,*999)

                  ENDDO !solver_idx
                ELSE
                  CALL FlagError("Control loop solvers is not associated.",err,error,*999)
                ENDIF
              ELSE
                !If there are sub loops the recursively solve those control loops
                DO loop_idx=1,CONTROL_LOOP%NUMBER_OF_SUB_LOOPS
                  CONTROL_LOOP2=>CONTROL_LOOP%SUB_LOOPS(loop_idx)%PTR
                  CALL PROBLEM_CONTROL_LOOP_SOLVE(CONTROL_LOOP2,err,error,*999)
                ENDDO !loop_idx
              ENDIF
              CALL PROBLEM_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
            ENDDO !iteration_idx
          ELSE
            CALL FlagError("Control loop fixed loop is not associated.",err,error,*999)
          ENDIF
        CASE(PROBLEM_CONTROL_TIME_LOOP_TYPE)
          TIME_LOOP=>CONTROL_LOOP%TIME_LOOP
          IF(ASSOCIATED(TIME_LOOP)) THEN
            !Set the current time to be the start time. Solvers should use the first time step to do any initialisation.
            TIME_LOOP%CURRENT_TIME=TIME_LOOP%START_TIME
            
            !Precompute the number of iterations from total time span and time increment if it was not specified explicitely 
            IF(TIME_LOOP%NUMBER_OF_ITERATIONS==0) THEN
              TIME_LOOP%NUMBER_OF_ITERATIONS=CEILING((TIME_LOOP%STOP_TIME-TIME_LOOP%START_TIME)/TIME_LOOP%TIME_INCREMENT)
            !If number of iterations was specified but does not match TIME_INCREMENT, e.g. TIME_INCREMENT is still at the default value, compute correct TIME_INCREMENT
            ELSE IF(CEILING((TIME_LOOP%STOP_TIME-TIME_LOOP%START_TIME)/TIME_LOOP%TIME_INCREMENT) &
              & /= TIME_LOOP%NUMBER_OF_ITERATIONS) THEN
              TIME_LOOP%TIME_INCREMENT = (TIME_LOOP%STOP_TIME-TIME_LOOP%START_TIME)/TIME_LOOP%NUMBER_OF_ITERATIONS
            ENDIF
            
            TIME_LOOP%ITERATION_NUMBER=0
                
            DO WHILE(TIME_LOOP%ITERATION_NUMBER<TIME_LOOP%NUMBER_OF_ITERATIONS)
              IF(CONTROL_LOOP%outputType>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
                CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Time control loop iteration: ",TIME_LOOP%ITERATION_NUMBER, &
                  & err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Total number of iterations: ",TIME_LOOP%NUMBER_OF_ITERATIONS, &
                  & err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Current time   = ",TIME_LOOP%CURRENT_TIME,err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Stop time      = ",TIME_LOOP%STOP_TIME,err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Time increment = ",TIME_LOOP%TIME_INCREMENT,err,error,*999)
              ENDIF
              IF(diagnostics1) THEN
                CALL WriteString(DIAGNOSTIC_OUTPUT_TYPE,"",err,error,*999)
                CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"Time control loop iteration: ",TIME_LOOP%ITERATION_NUMBER, &
                  & err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Total number of iterations: ",TIME_LOOP%NUMBER_OF_ITERATIONS, &
                  & err,error,*999)
                CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  Current time   = ",TIME_LOOP%CURRENT_TIME,err,error,*999)
                CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  Stop time      = ",TIME_LOOP%STOP_TIME,err,error,*999)
                CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  Time increment = ",TIME_LOOP%TIME_INCREMENT,err,error,*999)
              ENDIF
              !Perform any pre-loop actions.
              CALL PROBLEM_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*999)
              IF(CONTROL_LOOP%NUMBER_OF_SUB_LOOPS==0) THEN
                !If there are no sub loops then solve.
                SOLVERS=>CONTROL_LOOP%SOLVERS
                IF(ASSOCIATED(SOLVERS)) THEN
                  DO solver_idx=1,SOLVERS%NUMBER_OF_SOLVERS
                    SOLVER=>SOLVERS%SOLVERS(solver_idx)%PTR
                    
                    CALL Problem_SolverSolve(solver,err,error,*999)
                    
                  ENDDO !solver_idx
                ELSE
                  CALL FlagError("Control loop solvers is not associated.",err,error,*999)
                ENDIF
              ELSE
                !If there are sub loops the recursively solve those control loops
                DO loop_idx=1,CONTROL_LOOP%NUMBER_OF_SUB_LOOPS
                  CONTROL_LOOP2=>CONTROL_LOOP%SUB_LOOPS(loop_idx)%PTR
                  CALL PROBLEM_CONTROL_LOOP_SOLVE(CONTROL_LOOP2,err,error,*999)
                ENDDO !loop_idx
              ENDIF
              !Perform any post loop actions.
              CALL PROBLEM_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
              !Increment loop counter and time
              TIME_LOOP%ITERATION_NUMBER=TIME_LOOP%ITERATION_NUMBER+1
              TIME_LOOP%GLOBAL_ITERATION_NUMBER=TIME_LOOP%GLOBAL_ITERATION_NUMBER+1
              TIME_LOOP%CURRENT_TIME=TIME_LOOP%CURRENT_TIME+TIME_LOOP%TIME_INCREMENT
            ENDDO !time loop
          ELSE
            CALL FlagError("Control loop time loop is not associated.",err,error,*999)
          ENDIF
        CASE(PROBLEM_CONTROL_WHILE_LOOP_TYPE)
          WHILE_LOOP=>CONTROL_LOOP%WHILE_LOOP
          IF(ASSOCIATED(WHILE_LOOP)) THEN
            WHILE_LOOP%ITERATION_NUMBER=0
            WHILE_LOOP%CONTINUE_LOOP=.TRUE.
            DO WHILE(WHILE_LOOP%CONTINUE_LOOP.AND.WHILE_LOOP%ITERATION_NUMBER &
              & <WHILE_LOOP%MAXIMUM_NUMBER_OF_ITERATIONS)
              WHILE_LOOP%ITERATION_NUMBER=WHILE_LOOP%ITERATION_NUMBER+1
              IF(CONTROL_LOOP%outputType>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
                CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"While control loop iteration: ",WHILE_LOOP%ITERATION_NUMBER, &
                  & err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Maximum number of iterations = ", &
                  & WHILE_LOOP%MAXIMUM_NUMBER_OF_ITERATIONS,err,error,*999)
              ENDIF
              IF(diagnostics1) THEN
                CALL WriteString(DIAGNOSTIC_OUTPUT_TYPE,"",err,error,*999)
                CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"While control loop iteration: ",WHILE_LOOP%ITERATION_NUMBER, &
                  & err,error,*999)
                CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  Maximum number of iterations = ", &
                  & WHILE_LOOP%MAXIMUM_NUMBER_OF_ITERATIONS,err,error,*999)
              ENDIF
              CALL PROBLEM_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*999)
              IF(CONTROL_LOOP%NUMBER_OF_SUB_LOOPS==0) THEN
                !If there are no sub loops then solve
                SOLVERS=>CONTROL_LOOP%SOLVERS
                IF(ASSOCIATED(SOLVERS)) THEN
                  DO solver_idx=1,SOLVERS%NUMBER_OF_SOLVERS
                    SOLVER=>SOLVERS%SOLVERS(solver_idx)%PTR
                    IF(ASSOCIATED(SOLVER)) THEN
                      IF(ASSOCIATED(SOLVER%SOLVER_EQUATIONS)) THEN
                        CALL PROBLEM_SOLVER_LOAD_INCREMENT_APPLY(SOLVER%SOLVER_EQUATIONS,1, &
                          & 1,err,error,*999)
                      ENDIF
                      CALL Problem_SolverSolve(solver,err,error,*999)
                    ELSE
                      CALL FlagError("Solver is not associated.",err,error,*999)
                    ENDIF
                  ENDDO !solver_idx
                ELSE
                  CALL FlagError("Control loop solvers is not associated.",err,error,*999)
                ENDIF
              ELSE
                !If there are sub loops the recursively solve those control loops
                DO loop_idx=1,CONTROL_LOOP%NUMBER_OF_SUB_LOOPS
                  CONTROL_LOOP2=>CONTROL_LOOP%SUB_LOOPS(loop_idx)%PTR
                  CALL PROBLEM_CONTROL_LOOP_SOLVE(CONTROL_LOOP2,err,error,*999)
                ENDDO !loop_idx
              ENDIF
              CALL PROBLEM_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
            ENDDO !while loop
          ELSE
            CALL FlagError("Control loop while loop is not associated.",err,error,*999)
          ENDIF
        CASE(PROBLEM_CONTROL_LOAD_INCREMENT_LOOP_TYPE)
          LOAD_INCREMENT_LOOP=>CONTROL_LOOP%LOAD_INCREMENT_LOOP
          IF(ASSOCIATED(LOAD_INCREMENT_LOOP)) THEN
            LOAD_INCREMENT_LOOP%ITERATION_NUMBER=0
            IF (LOAD_INCREMENT_LOOP%MAXIMUM_NUMBER_OF_ITERATIONS<1) THEN
              ! automatic stepping
              CALL FlagError("Automatic load incrementing is not implemented yet.",err,error,*999)
            ELSE
              ! fixed number of steps
              DO WHILE(LOAD_INCREMENT_LOOP%ITERATION_NUMBER<LOAD_INCREMENT_LOOP%MAXIMUM_NUMBER_OF_ITERATIONS)
                LOAD_INCREMENT_LOOP%ITERATION_NUMBER=LOAD_INCREMENT_LOOP%ITERATION_NUMBER+1
                IF(CONTROL_LOOP%outputType>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
                  CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
                  CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Load increment control loop iteration: ", &
                    & LOAD_INCREMENT_LOOP%ITERATION_NUMBER,err,error,*999)
                  CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Maximum number of iterations = ", &
                    & LOAD_INCREMENT_LOOP%MAXIMUM_NUMBER_OF_ITERATIONS,err,error,*999)
                ENDIF
                IF(diagnostics1) THEN
                  CALL WriteString(DIAGNOSTIC_OUTPUT_TYPE,"",err,error,*999)
                  CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"Load increment control loop iteration: ", &
                    & LOAD_INCREMENT_LOOP%ITERATION_NUMBER,err,error,*999)
                  CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  Maximum number of iterations = ", &
                    & LOAD_INCREMENT_LOOP%MAXIMUM_NUMBER_OF_ITERATIONS,err,error,*999)
                ENDIF
                CALL PROBLEM_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*999)
                IF(CONTROL_LOOP%NUMBER_OF_SUB_LOOPS==0) THEN
                  !If there are no sub loops then solve
                  SOLVERS=>CONTROL_LOOP%SOLVERS
                  IF(ASSOCIATED(SOLVERS)) THEN
                    DO solver_idx=1,SOLVERS%NUMBER_OF_SOLVERS
                      SOLVER=>SOLVERS%SOLVERS(solver_idx)%PTR
                      IF(ASSOCIATED(SOLVER)) THEN
                        IF(ASSOCIATED(SOLVER%SOLVER_EQUATIONS)) THEN
                          !Apply incremented boundary conditions here => 
                          CALL PROBLEM_SOLVER_LOAD_INCREMENT_APPLY(SOLVER%SOLVER_EQUATIONS,LOAD_INCREMENT_LOOP%ITERATION_NUMBER, &
                            & LOAD_INCREMENT_LOOP%MAXIMUM_NUMBER_OF_ITERATIONS,err,error,*999)
                        ENDIF
                        CALL Problem_SolverSolve(solver,err,error,*999)
                      ELSE
                        CALL FlagError("Solver is not associated.",err,error,*999)
                      ENDIF
                    ENDDO !solver_idx
                  ELSE
                    CALL FlagError("Control loop solvers is not associated.",err,error,*999)
                  ENDIF
                ELSE
                  !If there are sub loops the recursively solve those control loops
                  DO loop_idx=1,CONTROL_LOOP%NUMBER_OF_SUB_LOOPS
                    CONTROL_LOOP2=>CONTROL_LOOP%SUB_LOOPS(loop_idx)%PTR
                    CALL PROBLEM_CONTROL_LOOP_SOLVE(CONTROL_LOOP2,err,error,*999)
                  ENDDO !loop_idx
                ENDIF
                CALL PROBLEM_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
              ENDDO !while loop
            ENDIF
          ELSE
            CALL FlagError("Control loop while loop is not associated.",err,error,*999)
          ENDIF
        CASE DEFAULT
          localError="The control loop loop type of "//TRIM(NumberToVString(CONTROL_LOOP%LOOP_TYPE,"*",err,error))// &
            & " is invalid."
          CALL FlagError(localError,err,error,*999)
        END SELECT
      ELSE
        CALL FlagError("Control loop has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Control loop is not associated",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_CONTROL_LOOP_SOLVE")
    RETURN
999 ERRORSEXITS("PROBLEM_CONTROL_LOOP_SOLVE",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_CONTROL_LOOP_SOLVE

  !
  !================================================================================================================================
  !

  !>Finishes the process of creating a problem. \see OpenCMISS::cmfe_Problem_CreateFinish
  SUBROUTINE PROBLEM_CREATE_FINISH(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to finish creating.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: problem_idx
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO

    ENTERS("PROBLEM_CREATE_FINISH",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      !Initialise the problem setup information
      CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
      PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_INITIAL_TYPE
      PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_FINISH_ACTION
      !Finish the problem specific setup
      CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
      !Finalise the problem setup information
      CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
      !Finish the problem creation
      PROBLEM%PROBLEM_FINISHED=.TRUE.
    ELSE        
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
    
    IF(DIAGNOSTICS1) THEN
      CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"Number of problems = ",PROBLEMS%NUMBER_OF_PROBLEMS,err,error,*999)
      DO problem_idx=1,PROBLEMS%NUMBER_OF_PROBLEMS
        CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"Problem number  = ",problem_idx,err,error,*999)
        CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  User number     = ",PROBLEMS%PROBLEMS(problem_idx)%PTR%USER_NUMBER, &
          & err,error,*999)
        CALL WriteStringValue(DIAGNOSTIC_OUTPUT_TYPE,"  Global number   = ",PROBLEMS%PROBLEMS(problem_idx)%PTR%GLOBAL_NUMBER, &
          & err,error,*999)
        CALL WRITE_STRING_VECTOR(DIAGNOSTIC_OUTPUT_TYPE,1,1,SIZE(PROBLEMS%PROBLEMS(problem_idx)%PTR%SPECIFICATION,1),8,8, &
          & PROBLEMS%PROBLEMS(problem_idx)%PTR%SPECIFICATION,'("  Problem specification = ",8(X,I3))','(16X,8(X,I3))', &
          & err,error,*999)
      ENDDO !problem_idx    
    ENDIF
    
    EXITS("PROBLEM_CREATE_FINISH")
    RETURN
999 ERRORSEXITS("PROBLEM_CREATE_FINISH",err,error)    
    RETURN 1
   
  END SUBROUTINE PROBLEM_CREATE_FINISH
        
  !
  !================================================================================================================================
  !

  !>Starts the process of creating a problem defined by USER_NUMBER. \see OpenCMISS::cmfe_Problem_CreateStart
  SUBROUTINE PROBLEM_CREATE_START(USER_NUMBER,PROBLEM_SPECIFICATION,PROBLEM,err,error,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the problem to create
    INTEGER(INTG), INTENT(IN) :: PROBLEM_SPECIFICATION(:) !<The problem specification array, eg. [problem_class, problem_type, problem_subtype]
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<On return, a pointer to the created problem. Must not be associated on entry.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: problem_idx
    TYPE(PROBLEM_TYPE), POINTER :: NEW_PROBLEM
    TYPE(PROBLEM_PTR_TYPE), POINTER :: NEW_PROBLEMS(:)
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO
    TYPE(VARYING_STRING) :: localError
 
    NULLIFY(NEW_PROBLEM)
    NULLIFY(NEW_PROBLEMS)

    ENTERS("PROBLEM_CREATE_START",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      CALL FlagError("Problem is already associated.",err,error,*999)
    ELSE
      NULLIFY(PROBLEM)
      CALL PROBLEM_USER_NUMBER_FIND(USER_NUMBER,PROBLEM,err,error,*999)
      IF(ASSOCIATED(PROBLEM)) THEN
        localError="Problem number "//TRIM(NumberToVString(USER_NUMBER,"*",err,error))//" has already been created."
        CALL FlagError(localError,err,error,*999)
      ELSE
        !Allocate the new problem
        ALLOCATE(NEW_PROBLEM,STAT=ERR)
        IF(ERR/=0) CALL FlagError("Could not allocate new problem.",err,error,*999)
        !Initalise problem
        CALL PROBLEM_INITIALISE(NEW_PROBLEM,err,error,*999)
        !Set default problem values
        NEW_PROBLEM%USER_NUMBER=USER_NUMBER
        NEW_PROBLEM%GLOBAL_NUMBER=PROBLEMS%NUMBER_OF_PROBLEMS+1
        NEW_PROBLEM%PROBLEMS=>PROBLEMS
        !Set problem specification
        CALL Problem_SpecificationSet(NEW_PROBLEM,PROBLEM_SPECIFICATION,err,error,*999)
        !For compatibility with old code, set class, type and subtype
        NEW_PROBLEM%PROBLEM_FINISHED=.FALSE.
        !Initialise the problem setup information
        CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
        PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_INITIAL_TYPE
        PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_START_ACTION
        !Start problem specific setup
        CALL PROBLEM_SETUP(NEW_PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
        !Finalise the problem setup information
        CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
        !Add new problem into list of problems
        ALLOCATE(NEW_PROBLEMS(PROBLEMS%NUMBER_OF_PROBLEMS+1),STAT=ERR)
        IF(ERR/=0) CALL FlagError("Could not allocate new problems.",err,error,*999)
        DO problem_idx=1,PROBLEMS%NUMBER_OF_PROBLEMS
          NEW_PROBLEMS(problem_idx)%PTR=>PROBLEMS%PROBLEMS(problem_idx)%PTR
        ENDDO !problem_idx
        NEW_PROBLEMS(PROBLEMS%NUMBER_OF_PROBLEMS+1)%PTR=>NEW_PROBLEM
        IF(ASSOCIATED(PROBLEMS%PROBLEMS)) DEALLOCATE(PROBLEMS%PROBLEMS)
        PROBLEMS%PROBLEMS=>NEW_PROBLEMS
        PROBLEMS%NUMBER_OF_PROBLEMS=PROBLEMS%NUMBER_OF_PROBLEMS+1
        PROBLEM=>NEW_PROBLEM
      ENDIF
    ENDIF
    
    EXITS("PROBLEM_CREATE_START")
    RETURN
999 ERRORSEXITS("PROBLEM_CREATE_START",err,error)
    RETURN 1   
  END SUBROUTINE PROBLEM_CREATE_START
  
  !
  !================================================================================================================================
  !

  !>Destroys a problem. \see OpenCMISS::cmfe_Problem_Destroy
  SUBROUTINE PROBLEM_DESTROY(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to destroy 
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: problem_idx,problem_position
    TYPE(PROBLEM_PTR_TYPE), POINTER :: NEW_PROBLEMS(:)

    NULLIFY(NEW_PROBLEMS)

    ENTERS("PROBLEM_DESTROY",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      IF(ASSOCIATED(PROBLEMS%PROBLEMS)) THEN
        
        problem_position=PROBLEM%GLOBAL_NUMBER
      
        !Destroy all the problem components
        CALL PROBLEM_FINALISE(PROBLEM,err,error,*999)
        
        !Remove the problem from the list of problems
        IF(PROBLEMS%NUMBER_OF_PROBLEMS>1) THEN
          ALLOCATE(NEW_PROBLEMS(PROBLEMS%NUMBER_OF_PROBLEMS-1),STAT=ERR)
          IF(ERR/=0) CALL FlagError("Could not allocate new problems.",err,error,*999)
          DO problem_idx=1,PROBLEMS%NUMBER_OF_PROBLEMS
            IF(problem_idx<problem_position) THEN
              NEW_PROBLEMS(problem_idx)%PTR=>PROBLEMS%PROBLEMS(problem_idx)%PTR
            ELSE IF(problem_idx>problem_position) THEN
              PROBLEMS%PROBLEMS(problem_idx)%PTR%GLOBAL_NUMBER=PROBLEMS%PROBLEMS(problem_idx)%PTR%GLOBAL_NUMBER-1
              NEW_PROBLEMS(problem_idx-1)%PTR=>PROBLEMS%PROBLEMS(problem_idx)%PTR
            ENDIF
          ENDDO !problem_idx
          DEALLOCATE(PROBLEMS%PROBLEMS)
          PROBLEMS%PROBLEMS=>NEW_PROBLEMS
          PROBLEMS%NUMBER_OF_PROBLEMS=PROBLEMS%NUMBER_OF_PROBLEMS-1
        ELSE
          DEALLOCATE(PROBLEMS%PROBLEMS)
          PROBLEMS%NUMBER_OF_PROBLEMS=0
        ENDIF
        
      ELSE
        CALL FlagError("Problem problems is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*998)
    ENDIF    

    EXITS("PROBLEM_DESTROY")
    RETURN
999 IF(ASSOCIATED(NEW_PROBLEMS)) DEALLOCATE(NEW_PROBLEMS)
998 ERRORSEXITS("PROBLEM_DESTROY",err,error)
    RETURN 1   
  END SUBROUTINE PROBLEM_DESTROY
  
  !
  !================================================================================================================================
  !

  !>Finalise the problem setup and deallocate all memory.
  SUBROUTINE PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*)

    !Argument variables
    TYPE(PROBLEM_SETUP_TYPE), INTENT(OUT) :: PROBLEM_SETUP_INFO !<The problem setup to finalise.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables

    ENTERS("PROBLEM_SETUP_FINALISE",err,error,*999)

    PROBLEM_SETUP_INFO%SETUP_TYPE=0
    PROBLEM_SETUP_INFO%ACTION_TYPE=0
       
    EXITS("PROBLEM_SETUP_FINALISE")
    RETURN
999 ERRORSEXITS("PROBLEM_SETUP_FINALISE",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SETUP_FINALISE

 !
  !================================================================================================================================
  !

  !>Initialise the problem setup.
  SUBROUTINE PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*)

    !Argument variables
    TYPE(PROBLEM_SETUP_TYPE), INTENT(OUT) :: PROBLEM_SETUP_INFO !<The problem setup to intialise.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables

    ENTERS("PROBLEM_SETUP_INITIALISE",err,error,*999)

    PROBLEM_SETUP_INFO%SETUP_TYPE=0
    PROBLEM_SETUP_INFO%ACTION_TYPE=0
        
    EXITS("PROBLEM_SETUP_INITIALISE")
    RETURN
999 ERRORSEXITS("PROBLEM_SETUP_INITIALISE",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SETUP_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finalise the problem and deallocate all memory.
  SUBROUTINE PROBLEM_FINALISE(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to finalise.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables

    ENTERS("PROBLEM_FINALISE",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      IF(ASSOCIATED(PROBLEM%CONTROL_LOOP)) CALL ControlLoop_Destroy(PROBLEM%CONTROL_LOOP,err,error,*999)
      IF(ALLOCATED(PROBLEM%SPECIFICATION)) DEALLOCATE(PROBLEM%SPECIFICATION)
      DEALLOCATE(PROBLEM)
    ENDIF
       
    EXITS("PROBLEM_FINALISE")
    RETURN
999 ERRORSEXITS("PROBLEM_FINALISE",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises a problem.
  SUBROUTINE PROBLEM_INITIALISE(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<The pointer to the problem
    INTEGER(INTG), INTENT(OUT) :: err !<The error code !<The errror code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string !<The error string
    !Local Variables
 
    ENTERS("PROBLEM_INITIALISE",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      PROBLEM%USER_NUMBER=0
      PROBLEM%GLOBAL_NUMBER=0
      PROBLEM%PROBLEM_FINISHED=.FALSE.
      NULLIFY(PROBLEM%PROBLEMS)
      NULLIFY(PROBLEM%CONTROL_LOOP)
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_INITIALISE")
    RETURN
999 ERRORSEXITS("PROBLEM_INITIALISE",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finish the creation of the control for the problem. \see OpenCMISS::cmfe_Problem_ControlLoopCreateFinish
  SUBROUTINE PROBLEM_CONTROL_LOOP_CREATE_FINISH(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to finish the control for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO

    ENTERS("PROBLEM_CONTROL_LOOP_CREATE_FINISH",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      IF(ASSOCIATED(PROBLEM%CONTROL_LOOP)) THEN
        IF(PROBLEM%CONTROL_LOOP%CONTROL_LOOP_FINISHED) THEN
          CALL FlagError("Problem control loop has already been finished.",err,error,*999)
        ELSE
          !Initialise the problem setup information
          CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
          PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_CONTROL_TYPE
          PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_FINISH_ACTION
          !Finish problem specific startup
          CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
          !Finalise the problem setup information
          CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
          !Finish problem control creation
          PROBLEM%CONTROL_LOOP%CONTROL_LOOP_FINISHED=.TRUE.
        ENDIF
      ELSE
        CALL FlagError("The problem control loop is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
      
    EXITS("PROBLEM_CONTROL_LOOP_CREATE_FINISH")
    RETURN
999 ERRORSEXITS("PROBLEM_CONTROL_LOOP_CREATE_FINISH",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_CONTROL_LOOP_CREATE_FINISH
  
  !
  !================================================================================================================================
  !

  !>Start the creation of a control loop for a problem. \see OpenCMISS::cmfe_Problem_ControlLoopCreateStart
  !>The default values of the PROBLEM CONTROL LOOP attributes are:
  !>- LOOP_TYPE: PROBLEM_CONTROL_SIMPLE_TYPE
  !>- CONTROL_LOOP_LEVEL: 1
  !>- NUMBER_OF_SUB_LOOPS: 0
  SUBROUTINE PROBLEM_CONTROL_LOOP_CREATE_START(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to start the creation of a control for.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO

    ENTERS("PROBLEM_CONTROL_LOOP_CREATE_START",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      IF(ASSOCIATED(PROBLEM%CONTROL_LOOP)) THEN
        CALL FlagError("The problem control loop is already associated.",err,error,*999)        
      ELSE
        !Initialise the problem setup information
        CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
        PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_CONTROL_TYPE
        PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_START_ACTION
        !Start the problem specific control setup
        CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
        !Finalise the problem setup information
        CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_CONTROL_LOOP_CREATE_START")
    RETURN
999 ERRORSEXITS("PROBLEM_CONTROL_LOOP_CREATE_START",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_CONTROL_LOOP_CREATE_START

  !
  !================================================================================================================================
  !

  !>Destroy the control loop for a problem. \see OpenCMISS::cmfe_Problem_ControlLoopDestroy
  SUBROUTINE PROBLEM_CONTROL_LOOP_DESTROY(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to destroy the control for.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables

    ENTERS("PROBLEM_CONTROL_LOOP_DESTROY",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      IF(ASSOCIATED(PROBLEM%CONTROL_LOOP)) THEN        
        CALL ControlLoop_Destroy(PROBLEM%CONTROL_LOOP,err,error,*999)
      ELSE
        CALL FlagError("Problem control loop is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_CONTROL_LOOP_DESTROY")
    RETURN
999 ERRORSEXITS("PROBLEM_CONTROL_LOOP_DESTROY",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_CONTROL_LOOP_DESTROY

  !
  !================================================================================================================================
  !

  !>Sets up the specifices for a problem.
  SUBROUTINE Problem_Setup(problem,problemSetupInfo,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: problem !<A pointer to the problem to setup
    TYPE(PROBLEM_SETUP_TYPE), INTENT(INOUT) :: problemSetupInfo !<The problem setup information.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: localError

    ENTERS("Problem_Setup",err,error,*999)

    IF(ASSOCIATED(problem)) THEN
      IF(.NOT.ALLOCATED(problem%specification)) THEN
        CALL FlagError("Problem specification is not allocated.",err,error,*999)
      ELSE IF(SIZE(problem%specification,1)<1) THEN
        CALL FlagError("Problem specification must have at least one entry.",err,error,*999)
      ENDIF
      SELECT CASE(problem%specification(1))
      CASE(PROBLEM_ELASTICITY_CLASS)
        CALL ELASTICITY_PROBLEM_SETUP(problem,problemSetupInfo,err,error,*999)
      CASE(PROBLEM_FLUID_MECHANICS_CLASS)
        CALL FLUID_MECHANICS_PROBLEM_SETUP(problem,problemSetupInfo,err,error,*999)
      CASE(PROBLEM_BIOELECTRICS_CLASS)
        CALL BIOELECTRIC_PROBLEM_SETUP(problem,problemSetupInfo,err,error,*999)
      CASE(PROBLEM_ELECTROMAGNETICS_CLASS)
        CALL FlagError("Not implemented.",err,error,*999)
      CASE(PROBLEM_CLASSICAL_FIELD_CLASS)
        CALL CLASSICAL_FIELD_PROBLEM_SETUP(problem,problemSetupInfo,err,error,*999)
      CASE(PROBLEM_FITTING_CLASS)
        CALL Fitting_ProblemSetup(problem,problemSetupInfo,err,error,*999)
      CASE(PROBLEM_MODAL_CLASS)
        CALL FlagError("Not implemented.",err,error,*999)
      CASE(PROBLEM_MULTI_PHYSICS_CLASS)
        CALL MULTI_PHYSICS_PROBLEM_SETUP(problem,problemSetupInfo,err,error,*999)
      CASE DEFAULT
        localError="The first problem specification of "//TRIM(NumberToVString(problem%specification(1),"*",err,error))// &
          & " is not valid."
        CALL FlagError(localError,err,error,*999)
      END SELECT
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("Problem_Setup")
    RETURN
999 ERRORSEXITS("Problem_Setup",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_Setup

  !
  !================================================================================================================================
  !

  !>Evaluates the Jacobian for a nonlinear problem solver.
  SUBROUTINE PROBLEM_SOLVER_JACOBIAN_EVALUATE(SOLVER,err,error,*)

   !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER, LINKING_SOLVER !<A pointer to the solver to evaluate the Jacobian for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx,solver_matrix_idx
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(SOLVER_TYPE), POINTER :: CELLML_SOLVER
    TYPE(NEWTON_SOLVER_TYPE), POINTER :: NEWTON_SOLVER
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(SOLVER_MATRICES_TYPE), POINTER :: SOLVER_MATRICES
    TYPE(SOLVER_MATRIX_TYPE), POINTER :: SOLVER_MATRIX
    TYPE(VARYING_STRING) :: localError
    
    ENTERS("PROBLEM_SOLVER_JACOBIAN_EVALUATE",err,error,*999)

    IF(ASSOCIATED(SOLVER)) THEN
      IF(SOLVER%SOLVER_FINISHED) THEN
        SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
        IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
          SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
          IF(ASSOCIATED(SOLVER_MAPPING)) THEN
            IF(SOLVER%outputType>=SOLVER_MATRIX_OUTPUT) THEN
              SOLVER_MATRICES=>SOLVER_EQUATIONS%SOLVER_MATRICES
              IF(ASSOCIATED(SOLVER_MATRICES)) THEN
                CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
                CALL WriteString(GENERAL_OUTPUT_TYPE,"Solver vector values:",err,error,*999)
                DO solver_matrix_idx=1,SOLVER_MATRICES%NUMBER_OF_MATRICES
                  SOLVER_MATRIX=>SOLVER_MATRICES%MATRICES(solver_matrix_idx)%PTR
                  IF(ASSOCIATED(SOLVER_MATRIX)) THEN
                    CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Solver matrix : ",solver_matrix_idx,err,error,*999)
                    CALL DistributedVector_Output(GENERAL_OUTPUT_TYPE,SOLVER_MATRIX%SOLVER_VECTOR,err,error,*999)
                  ELSE
                    localError="Solver matrix is not associated for solver matrix index "// &
                      & TRIM(NumberToVString(solver_matrix_idx,"*",err,error))//"."
                    CALL FlagError(localError,err,error,*999)
                  ENDIF
                ENDDO !solver_matrix_idx
              ELSE
                CALL FlagError("Solver equations solver matrices is not associated.",err,error,*999)
              ENDIF
            ENDIF
            IF(SOLVER%SOLVE_TYPE==SOLVER_NONLINEAR_TYPE) THEN
              !Check if the nonlinear solver is linked to a dynamic solver 
              LINKING_SOLVER=>SOLVER%LINKING_SOLVER
              IF(ASSOCIATED(LINKING_SOLVER)) THEN
                IF(LINKING_SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                  !Update the field values from the dynamic factor * current solver values AND add in mean predicted displacements/
                  CALL SOLVER_VARIABLES_DYNAMIC_NONLINEAR_UPDATE(SOLVER,err,error,*999)
                !check for a linked CellML solver 
!!TODO: This should be generalised for nonlinear solvers in general and not just Newton solvers.
                  NEWTON_SOLVER=>SOLVER%NONLINEAR_SOLVER%NEWTON_SOLVER
                  IF(ASSOCIATED(NEWTON_SOLVER)) THEN
                    CELLML_SOLVER=>NEWTON_SOLVER%CELLML_EVALUATOR_SOLVER
                    IF(ASSOCIATED(CELLML_SOLVER)) THEN
                      CALL SOLVER_SOLVE(CELLML_SOLVER,err,error,*999)
                    ENDIF
                  ELSE
                    CALL FlagError("Nonlinear solver Newton solver is not associated.",err,error,*999)
                  ENDIF
                  !Calculate the Jacobian
                  DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                    EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                    !Assemble the equations for dynamic problems
                    CALL EquationsSet_JacobianEvaluate(EQUATIONS_SET,err,error,*999)
                  ENDDO !equations_set_idx
                  !Assemble the dynamic nonlinear solver matrices
                  CALL SOLVER_MATRICES_DYNAMIC_ASSEMBLE(SOLVER,SOLVER_MATRICES_JACOBIAN_ONLY,err,error,*999)
                ELSE
                  CALL FlagError("Solver equations linking solver mapping is not dynamic.",err,error,*999)
                END IF
              ELSE
                !Otherwise perform as steady nonlinear
                !Copy the current solution vector to the dependent field
                CALL SOLVER_VARIABLES_FIELD_UPDATE(SOLVER,err,error,*999)
                !check for a linked CellML solver 
!!TODO: This should be generalised for nonlinear solvers in general and not just Newton solvers.
                NEWTON_SOLVER=>SOLVER%NONLINEAR_SOLVER%NEWTON_SOLVER
                IF(ASSOCIATED(NEWTON_SOLVER)) THEN
                  CELLML_SOLVER=>NEWTON_SOLVER%CELLML_EVALUATOR_SOLVER
                  IF(ASSOCIATED(CELLML_SOLVER)) THEN
                    CALL SOLVER_SOLVE(CELLML_SOLVER,err,error,*999)
                  ENDIF
                ELSE
                  CALL FlagError("Nonlinear solver Newton solver is not associated.",err,error,*999)
                ENDIF
                !Calculate the Jacobian
                DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                  EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                  !Assemble the equations for linear problems
                  CALL EquationsSet_JacobianEvaluate(EQUATIONS_SET,err,error,*999)
                ENDDO !equations_set_idx
                !Update interface matrices
!                DO interfaceConditionIdx=1,SOLVER_MAPPING%NUMBER_OF_INTERFACE_CONDITIONS
!                  interfaceCondition=>SOLVER_MAPPING%INTERFACE_CONDITIONS(interfaceConditionIdx)%PTR
!                  !Assemble the interface condition for the Jacobian LHS
!                  CALL WriteString(GENERAL_OUTPUT_TYPE,"********************Jacobian evaluation******************",err,error,*999)
!                  CALL INTERFACE_CONDITION_ASSEMBLE(interfaceCondition,err,error,*999)
!                ENDDO
                !Assemble the static nonlinear solver matrices
                CALL SOLVER_MATRICES_STATIC_ASSEMBLE(SOLVER,SOLVER_MATRICES_JACOBIAN_ONLY,err,error,*999)
              END IF       
            ELSE
              CALL FlagError("Solver equations solver type is not associated.",err,error,*999)
            END IF
          ELSE
            CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver solver equations mapping is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver is not associated.",err,error,*999)
    ENDIF    
    
    EXITS("PROBLEM_SOLVER_JACOBIAN_EVALUATE")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVER_JACOBIAN_EVALUATE",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVER_JACOBIAN_EVALUATE
  
  !
  !================================================================================================================================
  ! 

  !>Evaluates the residual for a nonlinear problem solver.
  SUBROUTINE PROBLEM_SOLVER_RESIDUAL_EVALUATE(SOLVER,err,error,*)

   !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver to evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx,solver_matrix_idx
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(SOLVER_TYPE), POINTER :: CELLML_SOLVER,LINKING_SOLVER
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(SOLVER_MATRICES_TYPE), POINTER :: SOLVER_MATRICES
    TYPE(SOLVER_MATRIX_TYPE), POINTER :: SOLVER_MATRIX
    
    TYPE(VARYING_STRING) :: localError
    
    NULLIFY(CELLML_SOLVER)
    NULLIFY(LINKING_SOLVER)

    ENTERS("PROBLEM_SOLVER_RESIDUAL_EVALUATE",err,error,*999)

    IF(ASSOCIATED(SOLVER)) THEN
      IF(SOLVER%SOLVER_FINISHED) THEN
        SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
        IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
          SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
          IF(ASSOCIATED(SOLVER_MAPPING)) THEN
            IF(SOLVER%outputType>=SOLVER_MATRIX_OUTPUT) THEN
              SOLVER_MATRICES=>SOLVER_EQUATIONS%SOLVER_MATRICES
              IF(ASSOCIATED(SOLVER_MATRICES)) THEN
                CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
                CALL WriteString(GENERAL_OUTPUT_TYPE,"Solver vector values:",err,error,*999)
                DO solver_matrix_idx=1,SOLVER_MATRICES%NUMBER_OF_MATRICES
                  SOLVER_MATRIX=>SOLVER_MATRICES%MATRICES(solver_matrix_idx)%PTR
                  IF(ASSOCIATED(SOLVER_MATRIX)) THEN
                    CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Solver matrix : ",solver_matrix_idx,err,error,*999)
                    CALL DistributedVector_Output(GENERAL_OUTPUT_TYPE,SOLVER_MATRIX%SOLVER_VECTOR,err,error,*999)
                  ELSE
                    localError="Solver matrix is not associated for solver matrix index "// &
                      & TRIM(NumberToVString(solver_matrix_idx,"*",err,error))//"."
                    CALL FlagError(localError,err,error,*999)
                  ENDIF
                ENDDO !solver_matrix_idx
              ELSE
                CALL FlagError("Solver equations solver matrices is not associated.",err,error,*999)
              ENDIF
            ENDIF
            IF(SOLVER%SOLVE_TYPE==SOLVER_NONLINEAR_TYPE) THEN
              !Check if the nonlinear solver is linked to a dynamic solver 
              LINKING_SOLVER=>SOLVER%LINKING_SOLVER
              IF(ASSOCIATED(LINKING_SOLVER)) THEN
                IF(LINKING_SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                  !Update the field values from the dynamic factor*current solver values AND add in predicted displacements
                  CALL SOLVER_VARIABLES_DYNAMIC_NONLINEAR_UPDATE(SOLVER,err,error,*999)
                  !Caculate the strain field for an CellML evaluator solver
                  CALL PROBLEM_PRE_RESIDUAL_EVALUATE(SOLVER,err,error,*999)
                  !check for a linked CellML solver

!!TODO: This should be generalised for nonlinear solvers in general and not just Newton solvers.
                  SELECT CASE(SOLVER%NONLINEAR_SOLVER%NONLINEAR_SOLVE_TYPE)
                  CASE(SOLVER_NONLINEAR_NEWTON)
                    CELLML_SOLVER=>SOLVER%NONLINEAR_SOLVER%NEWTON_SOLVER%CELLML_EVALUATOR_SOLVER
                  CASE(SOLVER_NONLINEAR_QUASI_NEWTON)
                    CELLML_SOLVER=>SOLVER%NONLINEAR_SOLVER%QUASI_NEWTON_SOLVER%CELLML_EVALUATOR_SOLVER
                  CASE DEFAULT
                    localError="Linked CellML solver is not implemented for nonlinear solver type " &
                      & //TRIM(NumberToVString(SOLVER%NONLINEAR_SOLVER%NONLINEAR_SOLVE_TYPE,"*",err,error))//"."
                    CALL FlagError(localError,err,error,*999)
                  END SELECT
                  IF(ASSOCIATED(CELLML_SOLVER)) CALL SOLVER_SOLVE(CELLML_SOLVER,err,error,*999)
                  !Calculate the residual for each element (M, C, K and g)
                  DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                    EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                    SELECT CASE(EQUATIONS_SET%EQUATIONS%linearity)
                    CASE(EQUATIONS_LINEAR)
                      !Assemble the equations for linear equations
                      CALL EQUATIONS_SET_ASSEMBLE(EQUATIONS_SET,err,error,*999)
                    CASE(EQUATIONS_NONLINEAR)
                      !Evaluate the residual for nonlinear equations
                      CALL EquationsSet_ResidualEvaluate(EQUATIONS_SET,err,error,*999)
                    END SELECT
                  ENDDO !equations_set_idx
                  !Assemble the final solver residual.
                  CALL SOLVER_MATRICES_DYNAMIC_ASSEMBLE(SOLVER,SOLVER_MATRICES_RHS_RESIDUAL_ONLY,err,error,*999)
                ELSE
                  CALL FlagError("Solver equations linking solver mapping is not dynamic.",err,error,*999)
                END IF
              ELSE
                !Perform as normal nonlinear solver
                !Copy the current solution vector to the dependent field
                CALL SOLVER_VARIABLES_FIELD_UPDATE(SOLVER,err,error,*999)
                !Caculate the strain field for an CellML evaluator solver
                CALL PROBLEM_PRE_RESIDUAL_EVALUATE(SOLVER,err,error,*999)
                !check for a linked CellML solver
!!TODO: This should be generalised for nonlinear solvers in general and not just Newton solvers.
                SELECT CASE(SOLVER%NONLINEAR_SOLVER%NONLINEAR_SOLVE_TYPE)
                CASE(SOLVER_NONLINEAR_NEWTON)
                  CELLML_SOLVER=>SOLVER%NONLINEAR_SOLVER%NEWTON_SOLVER%CELLML_EVALUATOR_SOLVER
                CASE(SOLVER_NONLINEAR_QUASI_NEWTON)
                  CELLML_SOLVER=>SOLVER%NONLINEAR_SOLVER%QUASI_NEWTON_SOLVER%CELLML_EVALUATOR_SOLVER
                CASE DEFAULT
                  localError="Linked CellML solver is not implemented for nonlinear solver type " &
                    & //TRIM(NumberToVString(SOLVER%NONLINEAR_SOLVER%NONLINEAR_SOLVE_TYPE,"*",err,error))//"."
                  CALL FlagError(localError,err,error,*999)
                END SELECT
                IF(ASSOCIATED(CELLML_SOLVER)) CALL SOLVER_SOLVE(CELLML_SOLVER,err,error,*999)
                !Make sure the equations sets are up to date
                DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                  EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                  SELECT CASE(EQUATIONS_SET%EQUATIONS%linearity)
                  CASE(EQUATIONS_LINEAR)
                    !Assemble the equations for linear equations
                    CALL EQUATIONS_SET_ASSEMBLE(EQUATIONS_SET,err,error,*999)
                  CASE(EQUATIONS_NONLINEAR)
                    !Evaluate the residual for nonlinear equations
                    CALL EquationsSet_ResidualEvaluate(EQUATIONS_SET,err,error,*999)
                  END SELECT
                ENDDO !equations_set_idx
                !Note that the linear interface matrices are not required to be updated since these matrices do not change
                !Update interface matrices
!                DO interfaceConditionIdx=1,SOLVER_MAPPING%NUMBER_OF_INTERFACE_CONDITIONS
!                  interfaceCondition=>SOLVER_MAPPING%INTERFACE_CONDITIONS(interfaceConditionIdx)%PTR
!                  !Assemble the interface condition for the Jacobian LHS
!                  CALL WriteString(GENERAL_OUTPUT_TYPE,"********************Residual evaluation******************",err,error,*999)
!                  CALL INTERFACE_CONDITION_ASSEMBLE(interfaceCondition,err,error,*999)
!                ENDDO
                !Assemble the solver matrices
                CALL SOLVER_MATRICES_STATIC_ASSEMBLE(SOLVER,SOLVER_MATRICES_RHS_RESIDUAL_ONLY,err,error,*999)
              END IF
            ELSE
               CALL FlagError("Solver equations solver type is not associated.",err,error,*999)
            END IF
          ELSE
            CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver solver equations mapping is not associated.",err,error,*999)
        ENDIF
        CALL PROBLEM_POST_RESIDUAL_EVALUATE(SOLVER,err,error,*999)
      ELSE
        CALL FlagError("Solver has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver is not associated.",err,error,*999)
    ENDIF    
    
    EXITS("PROBLEM_SOLVER_RESIDUAL_EVALUATE")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVER_RESIDUAL_EVALUATE",err,error)
    RETURN 1
    
  END SUBROUTINE PROBLEM_SOLVER_RESIDUAL_EVALUATE

  !
  !================================================================================================================================
  !

  !>Pre-evaluates the residual for the solver
  SUBROUTINE PROBLEM_PRE_RESIDUAL_EVALUATE(SOLVER,err,error,*)

    !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer the solver to pre-evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(EquationsType), POINTER :: EQUATIONS
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(VARYING_STRING) :: localError

    ENTERS("PROBLEM_PRE_RESIDUAL_EVALUATE",err,error,*999)

    IF(ASSOCIATED(SOLVER)) THEN
      IF(SOLVER%SOLVER_FINISHED) THEN
        IF(SOLVER%outputType>=SOLVER_PROGRESS_OUTPUT) THEN
          CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
          CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Solver pre-residual: ",SOLVER%LABEL,err,error,*999)
        ENDIF
        SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
        IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
          SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
          IF(ASSOCIATED(SOLVER_MAPPING)) THEN
            DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
              EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
              IF(ASSOCIATED(EQUATIONS_SET)) THEN
                EQUATIONS=>EQUATIONS_SET%EQUATIONS
                IF(ASSOCIATED(EQUATIONS)) THEN
                  IF(equations%equationsFinished) THEN
                    SELECT CASE(EQUATIONS%linearity)
                    CASE(EQUATIONS_LINEAR)            
                      CALL FlagError("Can not pre-evaluate a residual for linear equations.",err,error,*999)
                    CASE(EQUATIONS_NONLINEAR)
                      SELECT CASE(EQUATIONS%timeDependence)
                      CASE(EQUATIONS_STATIC,EQUATIONS_QUASISTATIC,EQUATIONS_FIRST_ORDER_DYNAMIC) ! quasistatic handled like static
                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                        CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                          IF(.NOT.ALLOCATED(EQUATIONS_SET%SPECIFICATION)) THEN
                            CALL FlagError("Equations set specification is not allocated.",err,error,*999)
                          ELSE IF(SIZE(EQUATIONS_SET%SPECIFICATION,1)<1) THEN
                            CALL FlagError("Equations set specification must have at least one entry.",err,error,*999)
                          ENDIF
                          SELECT CASE(EQUATIONS_SET%specification(1))
                          CASE(EQUATIONS_SET_ELASTICITY_CLASS)
                            CALL Elasticity_FiniteElementPreResidualEvaluate(EQUATIONS_SET,err,error,*999)
                          CASE(EQUATIONS_SET_FLUID_MECHANICS_CLASS)
                            CALL FluidMechanics_FiniteElementPreResidualEvaluate(EQUATIONS_SET,err,error,*999)
                          CASE(EQUATIONS_SET_ELECTROMAGNETICS_CLASS)
                            !Pre residual evaluate not used
                          CASE(EQUATIONS_SET_CLASSICAL_FIELD_CLASS)
                            !Pre residual evaluate not used
                          CASE(EQUATIONS_SET_BIOELECTRICS_CLASS)
                            !Pre residual evaluate not used
                          CASE(EQUATIONS_SET_MODAL_CLASS)
                            !Pre residual evaluate not used
                          CASE(EQUATIONS_SET_MULTI_PHYSICS_CLASS)
                            !Pre residual evaluate not used
                          CASE DEFAULT
                            localError="The first equations set specification of "// &
                              & TRIM(NumberToVString(EQUATIONS_SET%specification(1),"*",err,error))//" is not valid."
                            CALL FlagError(localError,err,error,*999)
                          END SELECT !EQUATIONS_SET%SPECIFICATION(1)
                        CASE(EQUATIONS_SET_NODAL_SOLUTION_METHOD)
                          SELECT CASE(EQUATIONS_SET%SPECIFICATION(1))
                          CASE(EQUATIONS_SET_FLUID_MECHANICS_CLASS)
                            !Pre residual evaluate not used
                          CASE DEFAULT
                            localError="The first equations set specification of "// &
                              & TRIM(NumberToVString(EQUATIONS_SET%SPECIFICATION(1),"*",err,error))//" is not valid."
                            CALL FLAG_ERROR(localError,err,error,*999)
                          END SELECT !EQUATIONS_SET%SPECIFICATION(1)
                        CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE DEFAULT
                          localError="The equations set solution method  of "// &
                            & TRIM(NumberToVString(EQUATIONS_SET%SOLUTION_METHOD,"*",err,error))// &
                            & " is invalid."
                          CALL FlagError(localError,err,error,*999)
                        END SELECT !EQUATIONS_SET%SOLUTION_METHOD
                      CASE(EQUATIONS_SECOND_ORDER_DYNAMIC)
                        CALL FlagError("Not implemented.",err,error,*999)
                      CASE(EQUATIONS_TIME_STEPPING)
                        CALL FlagError("Not implemented.",err,error,*999)
                      CASE DEFAULT
                        localError="The equations set time dependence type of "// &
                          & TRIM(NumberToVString(EQUATIONS%timeDependence,"*",err,error))//" is invalid."
                        CALL FlagError(localError,err,error,*999)
                      END SELECT
                    CASE(EQUATIONS_NONLINEAR_BCS)
                      CALL FlagError("Not implemented.",err,error,*999)
                    CASE DEFAULT
                      localError="The equations linearity of "// &
                        & TRIM(NumberToVString(EQUATIONS%linearity,"*",err,error))//" is invalid."
                      CALL FlagError(localError,err,error,*999)
                    END SELECT
                  ELSE
                    CALL FlagError("Equations have not been finished.",err,error,*999)
                  ENDIF
                ELSE
                  CALL FlagError("Equations set equations is not associated.",err,error,*999)
                ENDIF      
              ELSE
                CALL FlagError("Equations set is not associated.",err,error,*999)
              ENDIF
            ENDDO !equations_set_idx
          ELSE
            CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver solver equations is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver is not associated.",err,error,*999)
    ENDIF    
       
    EXITS("PROBLEM_PRE_RESIDUAL_EVALUATE")
    RETURN
999 ERRORSEXITS("PROBLEM_PRE_RESIDUAL_EVALUATE",err,error)
    RETURN 1
    
  END SUBROUTINE PROBLEM_PRE_RESIDUAL_EVALUATE
     
  !
  !================================================================================================================================
  !

  !>Post-evaluates the residual for the solver
  SUBROUTINE PROBLEM_POST_RESIDUAL_EVALUATE(SOLVER,err,error,*)

    !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer the solver to post-evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(EquationsType), POINTER :: EQUATIONS
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(VARYING_STRING) :: localError

    ENTERS("PROBLEM_POST_RESIDUAL_EVALUATE",err,error,*999)

    IF(ASSOCIATED(SOLVER)) THEN
      IF(SOLVER%SOLVER_FINISHED) THEN
        IF(SOLVER%outputType>=SOLVER_PROGRESS_OUTPUT) THEN
          CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
          CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Solver post-residual: ",SOLVER%LABEL,err,error,*999)
        ENDIF
        SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
        IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
          SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
          IF(ASSOCIATED(SOLVER_MAPPING)) THEN
            DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
              EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
              IF(ASSOCIATED(EQUATIONS_SET)) THEN
                EQUATIONS=>EQUATIONS_SET%EQUATIONS
                IF(ASSOCIATED(EQUATIONS)) THEN
                  IF(equations%equationsFinished) THEN
                    SELECT CASE(EQUATIONS%linearity)
                    CASE(EQUATIONS_LINEAR)            
                      CALL FlagError("Can not post-evaluate a residual for linear equations.",err,error,*999)
                    CASE(EQUATIONS_NONLINEAR)
                      SELECT CASE(EQUATIONS%timeDependence)
                      CASE(EQUATIONS_STATIC,EQUATIONS_QUASISTATIC,EQUATIONS_FIRST_ORDER_DYNAMIC) ! quasistatic handled like static
                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                        CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                          IF(.NOT.ALLOCATED(EQUATIONS_SET%SPECIFICATION)) THEN
                            CALL FlagError("Equations set specification is not allocated.",err,error,*999)
                          ELSE IF(SIZE(EQUATIONS_SET%SPECIFICATION,1)<1) THEN
                            CALL FlagError("Equations set specification must have at least one entry.",err,error,*999)
                          END IF
                          SELECT CASE(EQUATIONS_SET%SPECIFICATION(1))
                          CASE(EQUATIONS_SET_ELASTICITY_CLASS)
                            CALL Elasticity_FiniteElementPostResidualEvaluate(EQUATIONS_SET,err,error,*999)
                          CASE(EQUATIONS_SET_FLUID_MECHANICS_CLASS)
                            !Post residual evaluate not used
                          CASE(EQUATIONS_SET_ELECTROMAGNETICS_CLASS)
                            !Post residual evaluate not used
                          CASE(EQUATIONS_SET_CLASSICAL_FIELD_CLASS)
                            !Post residual evaluate not used
                          CASE(EQUATIONS_SET_BIOELECTRICS_CLASS)
                            !Post residual evaluate not used
                          CASE(EQUATIONS_SET_MODAL_CLASS)
                            !Post residual evaluate not used
                          CASE(EQUATIONS_SET_MULTI_PHYSICS_CLASS)
                            !Post residual evaluate not used
                          CASE DEFAULT
                            localError="The first equations set specification of "// &
                              & TRIM(NumberToVString(EQUATIONS_SET%SPECIFICATION(1),"*",err,error))//" is not valid."
                            CALL FLAG_ERROR(localError,err,error,*999)
                          END SELECT !EQUATIONS_SET%SPECIFICATION(1)
                        CASE(EQUATIONS_SET_NODAL_SOLUTION_METHOD)
                          SELECT CASE(EQUATIONS_SET%SPECIFICATION(1))
                          CASE(EQUATIONS_SET_FLUID_MECHANICS_CLASS)
                            !Post residual evaluate not used
                          CASE DEFAULT
                            localError="The first equations set specification of "// &
                              & TRIM(NumberToVString(EQUATIONS_SET%specification(1),"*",err,error))// &
                              & " is not valid with the nodal solution method."
                            CALL FLAG_ERROR(localError,err,error,*999)
                          END SELECT !EQUATIONS_SET%SPECIFICATION(1)
                        CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                          CALL FlagError("Not implemented.",err,error,*999)
                        CASE DEFAULT
                          localError="The equations set solution method  of "// &
                            & TRIM(NumberToVString(EQUATIONS_SET%SOLUTION_METHOD,"*",err,error))// &
                            & " is invalid."
                          CALL FlagError(localError,err,error,*999)
                        END SELECT !EQUATIONS_SET%SOLUTION_METHOD
                      CASE(EQUATIONS_SECOND_ORDER_DYNAMIC)
                        CALL FlagError("Not implemented.",err,error,*999)
                      CASE(EQUATIONS_TIME_STEPPING)
                        CALL FlagError("Not implemented.",err,error,*999)
                      CASE DEFAULT
                        localError="The equations set time dependence type of "// &
                          & TRIM(NumberToVString(EQUATIONS%timeDependence,"*",err,error))//" is invalid."
                        CALL FlagError(localError,err,error,*999)
                      END SELECT
                    CASE(EQUATIONS_NONLINEAR_BCS)
                      CALL FlagError("Not implemented.",err,error,*999)
                    CASE DEFAULT
                      localError="The equations linearity of "// &
                        & TRIM(NumberToVString(EQUATIONS%linearity,"*",err,error))//" is invalid."
                      CALL FlagError(localError,err,error,*999)
                    END SELECT
                  ELSE
                    CALL FlagError("Equations have not been finished.",err,error,*999)
                  ENDIF
                ELSE
                  CALL FlagError("Equations set equations is not associated.",err,error,*999)
                ENDIF      
              ELSE
                CALL FlagError("Equations set is not associated.",err,error,*999)
              ENDIF
            ENDDO !equations_set_idx
          ELSE
            CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver solver equations is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver is not associated.",err,error,*999)
    ENDIF    
       
    EXITS("PROBLEM_POST_RESIDUAL_EVALUATE")
    RETURN
999 ERRORSEXITS("PROBLEM_POST_RESIDUAL_EVALUATE",err,error)
    RETURN 1
    
  END SUBROUTINE PROBLEM_POST_RESIDUAL_EVALUATE

  !
  !================================================================================================================================
  !

  !>Finish the creation of solvers for a problem. \see OpenCMISS::cmfe_Problem_SolversCreateFinish
  SUBROUTINE PROBLEM_SOLVERS_CREATE_FINISH(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to finish the creation of the solvers for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO
     
    ENTERS("PROBLEM_SOLVERS_CREATE_FINISH",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN              
      !Initialise the problem setup information
      CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
      PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_SOLVERS_TYPE
      PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_FINISH_ACTION
      !Finish the problem specific solvers setup.
      CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
      !Finalise the problem setup information
      CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_SOLVERS_CREATE_FINISH")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVERS_CREATE_FINISH",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVERS_CREATE_FINISH
  
  !
  !================================================================================================================================
  !

  !>Start the creation of a solvers for the problem. \see OpenCMISS::cmfe_Problem_SolversCreateStart
  SUBROUTINE PROBLEM_SOLVERS_CREATE_START(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to create the solvers for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO

    ENTERS("PROBLEM_SOLVERS_CREATE_START",err,error,*999)
    
    IF(ASSOCIATED(PROBLEM)) THEN    
      !Initialise the problem setup information
      CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
      PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_SOLVERS_TYPE
      PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_START_ACTION
      !Start the problem specific solvers setup
      CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
      !Finalise the problem setup information
      CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
    
    EXITS("PROBLEM_SOLVERS_CREATE_START")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVERS_CREATE_START",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVERS_CREATE_START
  
  !
  !================================================================================================================================
  !

  !>Solves a problem. \see OpenCMISS::cmfe_Problem_Solve
  SUBROUTINE PROBLEM_SOLVE(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to solve.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP
    
    ENTERS("PROBLEM_SOLVE",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      IF(PROBLEM%PROBLEM_FINISHED) THEN
        CONTROL_LOOP=>PROBLEM%CONTROL_LOOP
        IF(ASSOCIATED(CONTROL_LOOP)) THEN
          CALL ControlLoop_FieldVariablesCalculate(CONTROL_LOOP,err,error,*999)
          CALL PROBLEM_CONTROL_LOOP_SOLVE(CONTROL_LOOP,err,error,*999)
        ELSE
          CALL FlagError("Problem control loop is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Problem has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_SOLVE")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVE",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVE

  !
  !================================================================================================================================
  !

  !> Apply the load increment for each equations_set associated with solver.
  SUBROUTINE PROBLEM_SOLVER_LOAD_INCREMENT_APPLY(SOLVER_EQUATIONS,ITERATION_NUMBER,MAXIMUM_NUMBER_OF_ITERATIONS,err,error,*)
    
    !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to solve
    INTEGER(INTG), INTENT(IN) :: ITERATION_NUMBER !<The current load increment iteration index
    INTEGER(INTG), INTENT(IN) :: MAXIMUM_NUMBER_OF_ITERATIONS !<Final index for load increment loop
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local variables
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    INTEGER(INTG) :: equations_set_idx

    ENTERS("PROBLEM_SOLVER_LOAD_INCREMENT_APPLY",err,error,*999)

    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
      IF(ASSOCIATED(SOLVER_MAPPING)) THEN
        !Make sure the equations sets are up to date
        DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
          EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
          CALL EQUATIONS_SET_LOAD_INCREMENT_APPLY(EQUATIONS_SET,SOLVER_EQUATIONS%BOUNDARY_CONDITIONS,ITERATION_NUMBER, &
            & MAXIMUM_NUMBER_OF_ITERATIONS,err,error,*999)
        ENDDO !equations_set_idx
      ELSE
        CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF
    
    EXITS("PROBLEM_SOLVER_LOAD_INCREMENT_APPLY")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVER_LOAD_INCREMENT_APPLY",err,error)
    RETURN 1

  END SUBROUTINE PROBLEM_SOLVER_LOAD_INCREMENT_APPLY

  !
  !================================================================================================================================
  !

  !>Executes before each loop of a control loop, ie before each time step for a time loop
  SUBROUTINE PROBLEM_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: localError

    ENTERS("PROBLEM_CONTROL_LOOP_PRE_LOOP",err,error,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(CONTROL_LOOP%outputType>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
        CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
        CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Control pre-loop: ",CONTROL_LOOP%LABEL,err,error,*999)
      ENDIF
      IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
        !For all time loops, update the previous values from the current values
        IF(CONTROL_LOOP%LOOP_TYPE==PROBLEM_CONTROL_TIME_LOOP_TYPE) THEN
          CALL ControlLoop_PreviousValuesUpdate(CONTROL_LOOP,err,error,*999)
        ENDIF
        IF(.NOT.ALLOCATED(CONTROL_LOOP%PROBLEM%SPECIFICATION)) THEN
          CALL FlagError("Problem specification is not allocated.",err,error,*999)
        ELSE IF(SIZE(CONTROL_LOOP%PROBLEM%SPECIFICATION,1)<1) THEN
          CALL FlagError("Problem specification must have at least one entry.",err,error,*999)
        END IF
        SELECT CASE(CONTROL_LOOP%PROBLEM%SPECIFICATION(1))
        CASE(PROBLEM_ELASTICITY_CLASS)
          CALL ELASTICITY_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*999)
        CASE(PROBLEM_BIOELECTRICS_CLASS)
          !do nothing
        CASE(PROBLEM_FLUID_MECHANICS_CLASS)
          CALL FLUID_MECHANICS_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*999)
        CASE(PROBLEM_ELECTROMAGNETICS_CLASS)
          !do nothing
        CASE(PROBLEM_CLASSICAL_FIELD_CLASS)
          !do nothing
        CASE(PROBLEM_FITTING_CLASS)
          !do nothing
        CASE(PROBLEM_MODAL_CLASS)
          !do nothing
        CASE(PROBLEM_MULTI_PHYSICS_CLASS)
          CALL MULTI_PHYSICS_CONTROL_LOOP_PRE_LOOP(CONTROL_LOOP,err,error,*999)
        CASE DEFAULT
          localError="Problem class "//TRIM(NumberToVString(CONTROL_LOOP%PROBLEM%SPECIFICATION(1),"*",err,error))//" &
            & is not valid."
          CALL FlagError(localError,err,error,*999)
        END SELECT
      ELSE
        CALL FlagError("Problem is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Control loop is not associated.",err,error,*999)
    ENDIF
    EXITS("PROBLEM_CONTROL_LOOP_PRE_LOOP")
    RETURN
999 ERRORSEXITS("PROBLEM_CONTROL_LOOP_PRE_LOOP",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_CONTROL_LOOP_PRE_LOOP

  !
  !================================================================================================================================
  !

  !>Executes after each loop of a control loop, ie after each time step for a time loop
  SUBROUTINE PROBLEM_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: localError
 
    ENTERS("PROBLEM_CONTROL_LOOP_POST_LOOP",err,error,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(CONTROL_LOOP%outputType>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
        CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
        CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Control post-loop: ",CONTROL_LOOP%LABEL,err,error,*999)
      ENDIF
      IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
        IF(.NOT.ALLOCATED(CONTROL_LOOP%PROBLEM%SPECIFICATION)) THEN
          CALL FlagError("Problem specification is not allocated.",err,error,*999)
        ELSE IF(SIZE(CONTROL_LOOP%PROBLEM%SPECIFICATION,1)<1) THEN
          CALL FlagError("Problem specification must have at least one entry.",err,error,*999)
        ENDIF
        SELECT CASE(CONTROL_LOOP%PROBLEM%SPECIFICATION(1))
        CASE(PROBLEM_ELASTICITY_CLASS)
          CALL Elasticity_ControlLoopPostLoop(CONTROL_LOOP,err,error,*999)
        CASE(PROBLEM_BIOELECTRICS_CLASS)
          CALL BIOELECTRIC_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
        CASE(PROBLEM_FLUID_MECHANICS_CLASS)
          CALL FLUID_MECHANICS_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
        CASE(PROBLEM_ELECTROMAGNETICS_CLASS)
          !Do nothing
        CASE(PROBLEM_CLASSICAL_FIELD_CLASS)
          IF(SIZE(CONTROL_LOOP%PROBLEM%SPECIFICATION,1)<2) THEN
            CALL FlagError("Problem specification must have at least two entries.",err,error,*999)
          ENDIF
          CALL CLASSICAL_FIELD_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)        
          SELECT CASE(CONTROL_LOOP%PROBLEM%SPECIFICATION(2))
          CASE(PROBLEM_REACTION_DIFFUSION_EQUATION_TYPE)
            CALL REACTION_DIFFUSION_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
          CASE DEFAULT
            !do nothing
          END SELECT
        CASE(PROBLEM_FITTING_CLASS)
          !Do nothing
        CASE(PROBLEM_MODAL_CLASS)
          !Do nothing
        CASE(PROBLEM_MULTI_PHYSICS_CLASS)
          CALL MULTI_PHYSICS_CONTROL_LOOP_POST_LOOP(CONTROL_LOOP,err,error,*999)
        CASE DEFAULT
          localError="The first problem specification of "// &
            & TRIM(NumberToVString(CONTROL_LOOP%problem%specification(1),"*",err,error))// &
            & " is not valid."
          CALL FlagError(localError,err,error,*999)
        END SELECT
      ELSE
        CALL FlagError("Problem is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Control loop is not associated.",err,error,*999)
    ENDIF
    
    EXITS("PROBLEM_CONTROL_LOOP_POST_LOOP")
    RETURN
999 ERRORSEXITS("PROBLEM_CONTROL_LOOP_POST_LOOP",err,error)
    RETURN 1
    
  END SUBROUTINE PROBLEM_CONTROL_LOOP_POST_LOOP

  !
  !================================================================================================================================
  !

  !>Executes pre solver routines for a problem.
  SUBROUTINE Problem_SolverPreSolve(solver,err,error,*)

    !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: solver !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: controlLoop
    TYPE(PROBLEM_TYPE), POINTER :: problem
    TYPE(SOLVERS_TYPE), POINTER :: SOLVERS
    TYPE(VARYING_STRING) :: localError

    ENTERS("Problem_SolverPreSolve",err,error,*999)

    IF(.NOT.ASSOCIATED(solver)) CALL FlagError("Solver is not associated.",err,error,*999)
    NULLIFY(controlLoop)
    CALL Solver_ControlLoopGet(solver,controlLoop,err,error,*999)
    NULLIFY(problem)
    CALL ControlLoop_ProblemGet(controlLoop,problem,err,error,*999)
    IF(.NOT.ALLOCATED(problem%specification)) CALL FlagError("Problem specification is not allocated.",err,error,*999)
    IF(SIZE(problem%specification,1)<1) &
      & CALL FlagError("Problem specification must have at least one entry.",err,error,*999)
    
    IF(solver%outputType>=SOLVER_PROGRESS_OUTPUT) THEN
      CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
      CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Solver pre-solve: ",solver%label,err,error,*999)
    ENDIF
    
    SELECT CASE(problem%specification(1))
    CASE(PROBLEM_ELASTICITY_CLASS)
      CALL ELASTICITY_PRE_SOLVE(controlLoop,solver,err,error,*999)
    CASE(PROBLEM_BIOELECTRICS_CLASS)
      CALL BIOELECTRIC_PRE_SOLVE(solver,err,error,*999)
    CASE(PROBLEM_FLUID_MECHANICS_CLASS)
      CALL FLUID_MECHANICS_PRE_SOLVE(controlLoop,solver,err,error,*999)
    CASE(PROBLEM_ELECTROMAGNETICS_CLASS)
      !Do nothing???
    CASE(PROBLEM_CLASSICAL_FIELD_CLASS)
      CALL ClassicalField_PreSolve(solver,err,error,*999)
    CASE(PROBLEM_FITTING_CLASS)
      CALL Fitting_PreSolve(solver,err,error,*999)
    CASE(PROBLEM_MODAL_CLASS)
      !Do nothing???
    CASE(PROBLEM_MULTI_PHYSICS_CLASS)
      CALL MULTI_PHYSICS_PRE_SOLVE(controlLoop,solver,err,error,*999)
    CASE DEFAULT
      localError="The problem class of "//TRIM(NumberToVString(problem%specification(1),"*",err,error))//" &
        & is invalid."
      CALL FlagError(localError,err,error,*999)
    END SELECT
    
    EXITS("Problem_SolverPreSolve")
    RETURN
999 ERRORSEXITS("Problem_SolverPreSolve",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SolverPreSolve

  !
  !================================================================================================================================
  !

  !>Executes post solver routines for a problem.
  SUBROUTINE Problem_SolverPostSolve(solver,err,error,*)

    !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: solver !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: controlLoop
    TYPE(PROBLEM_TYPE), POINTER :: problem
    TYPE(VARYING_STRING) :: localError
    
    ENTERS("Problem_SolverPostSolve",err,error,*999)

    IF(.NOT.ASSOCIATED(solver)) CALL FlagError("Solver is not associated.",err,error,*999)
    NULLIFY(controlLoop)
    CALL Solver_ControlLoopGet(solver,controlLoop,err,error,*999)
    NULLIFY(problem)
    CALL ControlLoop_ProblemGet(controlLoop,problem,err,error,*999)
    IF(.NOT.ALLOCATED(problem%specification)) CALL FlagError("Problem specification is not allocated.",err,error,*999)
    IF(SIZE(problem%specification,1)<1) &
      & CALL FlagError("Problem specification must have at least one entry.",err,error,*999)
    
    IF(solver%outputType>=SOLVER_PROGRESS_OUTPUT) THEN
      CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
      CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Solver post-solve: ",solver%label,err,error,*999)
    ENDIF
    
    SELECT CASE(problem%specification(1))
    CASE(PROBLEM_ELASTICITY_CLASS)
      CALL ELASTICITY_POST_SOLVE(controlLoop,solver,err,error,*999)
    CASE(PROBLEM_BIOELECTRICS_CLASS)
      CALL BIOELECTRIC_POST_SOLVE(solver,err,error,*999)
    CASE(PROBLEM_FLUID_MECHANICS_CLASS)
      CALL FLUID_MECHANICS_POST_SOLVE(controlLoop,solver,err,error,*999)
    CASE(PROBLEM_ELECTROMAGNETICS_CLASS)
      !Do nothing???
    CASE(PROBLEM_CLASSICAL_FIELD_CLASS)                
      CALL ClassicalField_PostSolve(solver,err,error,*999)
    CASE(PROBLEM_FITTING_CLASS)
      CALL Fitting_PostSolve(solver,err,error,*999)
    CASE(PROBLEM_MODAL_CLASS)
      !Do nothing???
    CASE(PROBLEM_MULTI_PHYSICS_CLASS)
      CALL MULTI_PHYSICS_POST_SOLVE(controlLoop,solver,err,error,*999)
    CASE DEFAULT
      localError="The problem class of "//TRIM(NumberToVString(problem%specification(1),"*",err,error))//" &
        & is invalid."
      CALL FlagError(localError,err,error,*999)
    END SELECT
      
    EXITS("Problem_SolverPostSolve")
    RETURN
999 ERRORSEXITS("Problem_SolverPostSolve",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SolverPostSolve

  !
  !================================================================================================================================
  !

  !>Solves solver equations for a problem.
  SUBROUTINE PROBLEM_SOLVER_EQUATIONS_SOLVE(SOLVER_EQUATIONS,err,error,*)

   !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(SOLVER_TYPE), POINTER :: solver
    TYPE(VARYING_STRING) :: localError
    
    ENTERS("PROBLEM_SOLVER_EQUATIONS_SOLVE",err,error,*999)
    
    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      IF(SOLVER_EQUATIONS%SOLVER_EQUATIONS_FINISHED) THEN
        NULLIFY(solver)
        CALL SolverEquations_SolverGet(SOLVER_EQUATIONS,solver,err,error,*999)
        IF(solver%outputType>=SOLVER_PROGRESS_OUTPUT) THEN
          CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
          CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Solver equations solve: ",solver%label,err,error,*999)
        ENDIF      
        SELECT CASE(SOLVER_EQUATIONS%timeDependence)
        CASE(SOLVER_EQUATIONS_STATIC)
          SELECT CASE(SOLVER_EQUATIONS%linearity)
          CASE(SOLVER_EQUATIONS_LINEAR)
            CALL Problem_SolverEquationsStaticLinearSolve(SOLVER_EQUATIONS,err,error,*999)
          CASE(SOLVER_EQUATIONS_NONLINEAR)
            CALL Problem_SolverEquationsStaticNonlinearSolve(SOLVER_EQUATIONS,err,error,*999)
          CASE DEFAULT
            localError="The solver equations linearity of "//TRIM(NumberToVString(SOLVER_EQUATIONS%linearity,"*",err,error))// &
              & " is invalid."
            CALL FlagError(localError,err,error,*999)
          END SELECT
        CASE(SOLVER_EQUATIONS_QUASISTATIC)
          SELECT CASE(SOLVER_EQUATIONS%linearity)
          CASE(SOLVER_EQUATIONS_LINEAR)
            CALL Problem_SolverEquationsQuasistaticLinearSolve(SOLVER_EQUATIONS,err,error,*999)
          CASE(SOLVER_EQUATIONS_NONLINEAR)
            CALL Problem_SolverEquationsQuasistaticNonlinearSolve(SOLVER_EQUATIONS,err,error,*999)
          CASE DEFAULT
            localError="The solver equations linearity of "//TRIM(NumberToVString(SOLVER_EQUATIONS%linearity,"*",err,error))// &
              & " is invalid."
            CALL FlagError(localError,err,error,*999)
          END SELECT
        CASE(SOLVER_EQUATIONS_FIRST_ORDER_DYNAMIC,SOLVER_EQUATIONS_SECOND_ORDER_DYNAMIC)
          SELECT CASE(SOLVER_EQUATIONS%linearity)
          CASE(SOLVER_EQUATIONS_LINEAR)
            CALL Problem_SolverEquationsDynamicLinearSolve(SOLVER_EQUATIONS,err,error,*999)
          CASE(SOLVER_EQUATIONS_NONLINEAR)
            CALL Problem_SolverEquationsDynamicNonlinearSolve(SOLVER_EQUATIONS,err,error,*999)
          CASE DEFAULT
            localError="The solver equations linearity of "//TRIM(NumberToVString(SOLVER_EQUATIONS%linearity,"*",err,error))// &
              & " is invalid."
            CALL FlagError(localError,err,error,*999)
          END SELECT
        CASE DEFAULT
          localError="The solver equations time dependence type of "// &
            & TRIM(NumberToVString(SOLVER_EQUATIONS%timeDependence,"*",err,error))//" is invalid."
          CALL FlagError(localError,err,error,*999)
        END SELECT
      ELSE
        CALL FlagError("Solver equations have not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF
    
    EXITS("PROBLEM_SOLVER_EQUATIONS_SOLVE")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVER_EQUATIONS_SOLVE",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVER_EQUATIONS_SOLVE

  !
  !================================================================================================================================
  !

  !>Solves dynamic linear solver equations.
  SUBROUTINE Problem_SolverEquationsDynamicLinearSolve(SOLVER_EQUATIONS,err,error,*)

    !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx,loop_idx
    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP,CONTROL_TIME_LOOP
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(SOLVER_TYPE), POINTER :: SOLVER
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(SOLVERS_TYPE), POINTER :: SOLVERS
    
    ENTERS("Problem_SolverEquationsDynamicLinearSolve",err,error,*999)
    
    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      SOLVER=>SOLVER_EQUATIONS%SOLVER
      IF(ASSOCIATED(SOLVER)) THEN
        SOLVERS=>SOLVER%SOLVERS
        IF(ASSOCIATED(SOLVERS)) THEN
          CONTROL_LOOP=>SOLVERS%CONTROL_LOOP
          IF(ASSOCIATED(CONTROL_LOOP)) THEN
            SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
            IF(ASSOCIATED(SOLVER_MAPPING)) THEN
              !Get current control loop times
              CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,err,error,*999)
              !Make sure the equations sets are up to date
              DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                !Set the equations set times
                CALL EquationsSet_TimesSet(EQUATIONS_SET,CURRENT_TIME,TIME_INCREMENT,err,error,*999)
                !Assemble the equations for linear problems
                CALL EQUATIONS_SET_ASSEMBLE(EQUATIONS_SET,err,error,*999)
              ENDDO !equations_set_idx
              !Set the solver time
              CALL SOLVER_DYNAMIC_TIMES_SET(SOLVER,CURRENT_TIME,TIME_INCREMENT,err,error,*999)
              !Solve for the next time i.e., current time + time increment
              CALL SOLVER_SOLVE(SOLVER,err,error,*999)
              !Back-substitute to find flux values for linear problems
              DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                CALL EQUATIONS_SET_BACKSUBSTITUTE(EQUATIONS_SET,SOLVER_EQUATIONS%BOUNDARY_CONDITIONS,err,error,*999)
              ENDDO !equations_set_idx
            ELSE
              CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
            ENDIF
          ELSE
            CALL FlagError("Solvers control loop is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver solvers is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver equations solver is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF
    
    EXITS("Problem_SolverEquationsDynamicLinearSolve")
    RETURN
999 ERRORSEXITS("Problem_SolverEquationsDynamicLinearSolve",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SolverEquationsDynamicLinearSolve

  !
  !================================================================================================================================
  !

  !>Solves dynamic nonlinear solver equations.
  SUBROUTINE Problem_SolverEquationsDynamicNonlinearSolve(SOLVER_EQUATIONS,err,error,*)
    
   !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx,loop_idx,interface_condition_idx
    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP,CONTROL_TIME_LOOP
    TYPE(EquationsType), POINTER :: EQUATIONS
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(INTERFACE_CONDITION_TYPE), POINTER :: INTERFACE_CONDITION
    TYPE(SOLVER_TYPE), POINTER :: SOLVER
    TYPE(DYNAMIC_SOLVER_TYPE), POINTER :: DYNAMIC_SOLVER
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(SOLVERS_TYPE), POINTER :: SOLVERS
    TYPE(VARYING_STRING) :: localError
    
    ENTERS("Problem_SolverEquationsDynamicNonlinearSolve",err,error,*999)
    
    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      SOLVER=>SOLVER_EQUATIONS%SOLVER
      IF(ASSOCIATED(SOLVER)) THEN
        DYNAMIC_SOLVER=>SOLVER%DYNAMIC_SOLVER
        IF(ASSOCIATED(DYNAMIC_SOLVER)) THEN
          SOLVERS=>SOLVER%SOLVERS
          IF(ASSOCIATED(SOLVER)) THEN
            CONTROL_LOOP=>SOLVERS%CONTROL_LOOP
            IF(ASSOCIATED(CONTROL_LOOP)) THEN
              SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
              IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                !Get current control loop times
                CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,err,error,*999)
                DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                  EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                  !Set the equations set times
                  CALL EquationsSet_TimesSet(EQUATIONS_SET,CURRENT_TIME,TIME_INCREMENT,err,error,*999)
                  IF(DYNAMIC_SOLVER%RESTART.OR..NOT.DYNAMIC_SOLVER%SOLVER_INITIALISED) THEN!.OR.DYNAMIC_SOLVER%FSI) THEN
                    !If we need to restart or we haven't initialised yet or we have an FSI scheme, make sure the equations sets are up to date
                    EQUATIONS=>EQUATIONS_SET%EQUATIONS
                    IF(ASSOCIATED(EQUATIONS)) THEN
                      SELECT CASE(EQUATIONS%linearity)
                      CASE(EQUATIONS_LINEAR)
                        !Assemble the equations
                        CALL EQUATIONS_SET_ASSEMBLE(EQUATIONS_SET,err,error,*999)
                      CASE(EQUATIONS_NONLINEAR)
                        !Evaluate the residuals
                        CALL EquationsSet_ResidualEvaluate(EQUATIONS_SET,err,error,*999)
                      CASE(EQUATIONS_NONLINEAR_BCS)
                        CALL FlagError("Not implemented.",err,error,*999)
                      CASE DEFAULT
                        localError="The equations linearity type of "// &
                          & TRIM(NumberToVString(EQUATIONS%linearity,"*",err,error))// &
                          & " is invalid."
                        CALL FlagError(localError,err,error,*999)
                      END SELECT
                    ELSE
                      CALL FlagError("Equations set equations is not associated.",err,error,*999)
                    ENDIF
                  ENDIF
                ENDDO !equations_set_idx
                !Make sure the interface matrices are up to date
                DO interface_condition_idx=1,SOLVER_MAPPING%NUMBER_OF_INTERFACE_CONDITIONS
                  INTERFACE_CONDITION=>SOLVER_MAPPING%INTERFACE_CONDITIONS(interface_condition_idx)%PTR
                  CALL INTERFACE_CONDITION_ASSEMBLE(INTERFACE_CONDITION,err,error,*999)
                ENDDO !interface_condition_idx
                !Set the solver time
                CALL SOLVER_DYNAMIC_TIMES_SET(SOLVER,CURRENT_TIME,TIME_INCREMENT,err,error,*999)
                !Solve for the next time i.e., current time + time increment
                CALL SOLVER_SOLVE(SOLVER,err,error,*999)
              ELSE
                CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
              ENDIF
            ELSE
              CALL FlagError("Solvers control loop is not associated.",err,error,*999)
            ENDIF
          ELSE
            CALL FlagError("Solver solvers is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver dynamic solver is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver equations solver is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF
    
    EXITS("Problem_SolverEquationsDynamicNonlinearSolve")
    RETURN
999 ERRORS("Problem_SolverEquationsDynamicNonlinearSolve",err,error)
    EXITS("Problem_SolverEquationsDynamicNonlinearSolve")
    RETURN 1
    
  END SUBROUTINE Problem_SolverEquationsDynamicNonlinearSolve

  !
  !================================================================================================================================
  !

  !>Solves quasistatic linear solver equations.
  SUBROUTINE Problem_SolverEquationsQuasistaticLinearSolve(SOLVER_EQUATIONS,err,error,*)
    
   !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx
    REAL(DP) :: currentTime,timeIncrement
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(SOLVER_TYPE), POINTER :: SOLVER
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(SOLVERS_TYPE), POINTER :: SOLVERS
     
    ENTERS("Problem_SolverEquationsQuasistaticLinearSolve",err,error,*999)
    
    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      SOLVER=>SOLVER_EQUATIONS%SOLVER
      IF(ASSOCIATED(SOLVER)) THEN
        SOLVERS=>SOLVER%SOLVERS
        IF(ASSOCIATED(SOLVERS)) THEN
          CONTROL_LOOP=>SOLVERS%CONTROL_LOOP
          IF(ASSOCIATED(CONTROL_LOOP)) THEN
            SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
            IF(ASSOCIATED(SOLVER_MAPPING)) THEN
              !Get current control loop times
              CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,currentTime,timeIncrement,err,error,*999)
              !Make sure the equations sets are up to date
              DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                !Set the current times
                CALL EquationsSet_TimesSet(EQUATIONS_SET,currentTime,timeIncrement,err,error,*999)
                !CALL EQUATIONS_SET_FIXED_CONDITIONS_APPLY(EQUATIONS_SET,err,error,*999)    
                !Assemble the equations for linear problems
                CALL EQUATIONS_SET_ASSEMBLE(EQUATIONS_SET,err,error,*999)
              ENDDO !equations_set_idx
              !Solve for the current time
              CALL SOLVER_SOLVE(SOLVER,err,error,*999)
              !Back-substitute to find flux values for linear problems
              DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                CALL EQUATIONS_SET_BACKSUBSTITUTE(EQUATIONS_SET,SOLVER_EQUATIONS%BOUNDARY_CONDITIONS,err,error,*999)
              ENDDO !equations_set_idx
            ELSE
              CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
            ENDIF
          ELSE
            CALL FlagError("Solvers control loop is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver solvers is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver equations solver is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF    
    
    EXITS("Problem_SolverEquationsQuasistaticLinearSolve")
    RETURN
999 ERRORS("Problem_SolverEquationsQuasistaticLinearSolve",err,error)
    EXITS("Problem_SolverEquationsQuasistaticLinearSolve")
    RETURN 1
    
  END SUBROUTINE Problem_SolverEquationsQuasistaticLinearSolve

  !
  !================================================================================================================================
  !

  !>Solves quasistatic nonlinear solver equations.
  SUBROUTINE Problem_SolverEquationsQuasistaticNonlinearSolve(SOLVER_EQUATIONS,err,error,*)
    
    !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx
    REAL(DP) :: currentTime,timeIncrement
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP
    TYPE(EquationsType), POINTER :: EQUATIONS
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(SOLVER_TYPE), POINTER :: SOLVER
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(SOLVERS_TYPE), POINTER :: SOLVERS
   
    ENTERS("Problem_SolverEquationsQuasistaticNonlinearSolve",err,error,*999)
    
    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      SOLVER=>SOLVER_EQUATIONS%SOLVER
      IF(ASSOCIATED(SOLVER)) THEN
        SOLVERS=>SOLVER%SOLVERS
        IF(ASSOCIATED(SOLVERS)) THEN
          CONTROL_LOOP=>SOLVERS%CONTROL_LOOP
          IF(ASSOCIATED(CONTROL_LOOP)) THEN
            SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
            IF(ASSOCIATED(SOLVER_MAPPING)) THEN
              !Get current control loop times
              CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,currentTime,timeIncrement,err,error,*999)
              !Make sure the equations sets are up to date
              DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                !Set the equations set times
                CALL EquationsSet_TimesSet(EQUATIONS_SET,currentTime,timeIncrement,err,error,*999)
                !CALL EQUATIONS_SET_FIXED_CONDITIONS_APPLY(EQUATIONS_SET,err,error,*999)
                !Assemble the equations for linear problems
                CALL EQUATIONS_SET_ASSEMBLE(EQUATIONS_SET,err,error,*999)
              ENDDO !equations_set_idx
              !Solve for the next time i.e., current time + time increment
              CALL SOLVER_SOLVE(SOLVER,err,error,*999)
              !Update the rhs field variable with residuals or backsubstitute for any linear
              !equations sets
              DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                EQUATIONS=>EQUATIONS_SET%EQUATIONS
                IF(ASSOCIATED(EQUATIONS)) THEN
                  SELECT CASE(EQUATIONS%linearity)
                  CASE(EQUATIONS_LINEAR,EQUATIONS_NONLINEAR_BCS)
                    CALL EQUATIONS_SET_BACKSUBSTITUTE(EQUATIONS_SET,SOLVER_EQUATIONS%BOUNDARY_CONDITIONS,err,error,*999)
                  CASE(EQUATIONS_NONLINEAR)
                    CALL EQUATIONS_SET_NONLINEAR_RHS_UPDATE(EQUATIONS_SET,SOLVER_EQUATIONS%BOUNDARY_CONDITIONS,err,error,*999)
                  CASE DEFAULT
                    CALL FlagError("Invalid linearity for equations set equations",err,error,*999)
                  END SELECT
                ELSE
                  CALL FlagError("Equations set equations is not associated.",err,error,*999)
                ENDIF
              ENDDO !equations_set_idx
            ELSE
              CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
            ENDIF
          ELSE
            CALL FlagError("Solvers control loop is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver solvers is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver equations solver is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF    
    
    EXITS("Problem_SolverEquationsQuasistaticNonlinearSolve")
    RETURN
999 ERRORS("Problem_SolverEquationsQuasistaticNonlinearSolve",err,error)
    EXITS("Problem_SolverEquationsQuasistaticNonlinearSolve")
    RETURN 1
    
  END SUBROUTINE Problem_SolverEquationsQuasistaticNonlinearSolve

  !
  !================================================================================================================================
  !

  !>Solves static linear solver equations.
  SUBROUTINE Problem_SolverEquationsStaticLinearSolve(SOLVER_EQUATIONS,err,error,*)

   !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx,interface_condition_idx
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(INTERFACE_CONDITION_TYPE), POINTER :: INTERFACE_CONDITION
    TYPE(SOLVER_TYPE), POINTER :: SOLVER
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    
#ifdef TAUPROF
    CHARACTER(12) :: CVAR
    INTEGER :: PHASE(2) = [ 0, 0 ]
    SAVE PHASE
#endif

    ENTERS("Problem_SolverEquationsStaticLinearSolve",err,error,*999)
    
    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      SOLVER=>SOLVER_EQUATIONS%SOLVER
      IF(ASSOCIATED(SOLVER)) THEN
        SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
        IF(ASSOCIATED(SOLVER_MAPPING)) THEN
          !Make sure the equations sets are up to date
          DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
#ifdef TAUPROF
            WRITE (CVAR,'(a8,i2)') 'Assemble',equations_set_idx
            CALL TAU_PHASE_CREATE_DYNAMIC(PHASE,CVAR)
            CALL TAU_PHASE_START(PHASE)
#endif
            EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
            !CALL EQUATIONS_SET_FIXED_CONDITIONS_APPLY(EQUATIONS_SET,err,error,*999)
            !Assemble the equations for linear problems
            CALL EQUATIONS_SET_ASSEMBLE(EQUATIONS_SET,err,error,*999)
#ifdef TAUPROF
            CALL TAU_PHASE_STOP(PHASE)
#endif
          ENDDO !equations_set_idx
          !Make sure the interface matrices are up to date
          DO interface_condition_idx=1,SOLVER_MAPPING%NUMBER_OF_INTERFACE_CONDITIONS
#ifdef TAUPROF
            WRITE (CVAR,'(a8,i2)') 'Interface',interface_condition_idx
            CALL TAU_PHASE_CREATE_DYNAMIC(PHASE,CVAR)
            CALL TAU_PHASE_START(PHASE)
#endif
            INTERFACE_CONDITION=>SOLVER_MAPPING%INTERFACE_CONDITIONS(interface_condition_idx)%PTR
            CALL INTERFACE_CONDITION_ASSEMBLE(INTERFACE_CONDITION,err,error,*999)
#ifdef TAUPROF
            CALL TAU_PHASE_STOP(PHASE)
#endif
          ENDDO !interface_condition_idx

          !Solve
          CALL SOLVER_SOLVE(SOLVER,err,error,*999)

#ifdef TAUPROF
          CALL TAU_STATIC_PHASE_START('EQUATIONS_SET_BACKSUBSTITUTE()')
#endif
          !Back-substitute to find flux values for linear problems
          DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
            EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
            CALL EQUATIONS_SET_BACKSUBSTITUTE(EQUATIONS_SET,SOLVER_EQUATIONS%BOUNDARY_CONDITIONS,err,error,*999)
          ENDDO !equations_set_idx
#ifdef TAUPROF
          CALL TAU_STATIC_PHASE_STOP('EQUATIONS_SET_BACKSUBSTITUTE()')
#endif
        ELSE
          CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver equations solver is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF    
    
    EXITS("Problem_SolverEquationsStaticLinearSolve")
    RETURN
999 ERRORSEXITS("Problem_SolverEquationsStaticLinearSolve",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SolverEquationsStaticLinearSolve
  
  !
  !================================================================================================================================
  !

  !>Solves static nonlinear solver equations.
  SUBROUTINE Problem_SolverEquationsStaticNonlinearSolve(SOLVER_EQUATIONS,err,error,*)
    
   !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx,interface_condition_idx
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(EquationsType), POINTER :: EQUATIONS
    TYPE(INTERFACE_CONDITION_TYPE), POINTER :: INTERFACE_CONDITION
    TYPE(SOLVER_TYPE), POINTER :: SOLVER
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    
#ifdef TAUPROF
    CHARACTER(12) :: CVAR
    INTEGER :: PHASE(2) = [ 0, 0 ]
    SAVE PHASE
#endif
    ENTERS("Problem_SolverEquationsStaticNonlinearSolve",err,error,*999)
    
    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      SOLVER=>SOLVER_EQUATIONS%SOLVER
      IF(ASSOCIATED(SOLVER)) THEN
        SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
        IF(ASSOCIATED(SOLVER_MAPPING)) THEN
          !Apply boundary conditition
          DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
            EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
            !Assemble the equations set
            CALL EQUATIONS_SET_ASSEMBLE(EQUATIONS_SET,err,error,*999)
          ENDDO !equations_set_idx
          !Make sure the interface matrices are up to date
          DO interface_condition_idx=1,SOLVER_MAPPING%NUMBER_OF_INTERFACE_CONDITIONS
#ifdef TAUPROF
            WRITE (CVAR,'(a8,i2)') 'Interface',interface_condition_idx
            CALL TAU_PHASE_CREATE_DYNAMIC(PHASE,CVAR)
            CALL TAU_PHASE_START(PHASE)
#endif
            INTERFACE_CONDITION=>SOLVER_MAPPING%INTERFACE_CONDITIONS(interface_condition_idx)%PTR
            CALL INTERFACE_CONDITION_ASSEMBLE(INTERFACE_CONDITION,err,error,*999)
#ifdef TAUPROF
            CALL TAU_PHASE_STOP(PHASE)
#endif
          ENDDO !interface_condition_idx
          !Solve
          CALL SOLVER_SOLVE(SOLVER,err,error,*999)
          !Update the rhs field variable with residuals or backsubstitute for any linear
          !equations sets
          DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
            EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
            EQUATIONS=>EQUATIONS_SET%EQUATIONS
            IF(ASSOCIATED(EQUATIONS)) THEN
              SELECT CASE(EQUATIONS%linearity)
              CASE(EQUATIONS_LINEAR,EQUATIONS_NONLINEAR_BCS)
                CALL EQUATIONS_SET_BACKSUBSTITUTE(EQUATIONS_SET,SOLVER_EQUATIONS%BOUNDARY_CONDITIONS,err,error,*999)
              CASE(EQUATIONS_NONLINEAR)
                CALL EQUATIONS_SET_NONLINEAR_RHS_UPDATE(EQUATIONS_SET,SOLVER_EQUATIONS%BOUNDARY_CONDITIONS,err,error,*999)
              CASE DEFAULT
                CALL FlagError("Invalid linearity for equations set equations",err,error,*999)
              END SELECT
            ELSE
              CALL FlagError("Equations set equations is not associated.",err,error,*999)
            ENDIF
          ENDDO !equations_set_idx
        ELSE
          CALL FlagError("Solver equations solver mapping not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver equations solver is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF
    
    EXITS("Problem_SolverEquationsStaticNonlinearSolve")
    RETURN
999 ERRORSEXITS("Problem_SolverEquationsStaticNonlinearSolve",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SolverEquationsStaticNonlinearSolve

  !
  !================================================================================================================================
  !


  !>Solves a solver for a problem.
  SUBROUTINE Problem_SolverSolve(solver,err,error,*)

   !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: solver !<A pointer to the solver to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    
    ENTERS("Problem_SolverSolve",err,error,*999)
    
    IF(.NOT.ASSOCIATED(solver)) CALL FlagError("Solver is not associated.",err,error,*999)

    IF(solver%outputType>=SOLVER_PROGRESS_OUTPUT) THEN
      CALL WriteString(GENERAL_OUTPUT_TYPE,"",err,error,*999)
      CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Solver: ",solver%label,err,error,*999)
      CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"  Solver index = ",solver%GLOBAL_NUMBER,err,error,*999)
    ENDIF
      
#ifdef TAUPROF
    CALL TAU_STATIC_PHASE_START('Pre solve')
#endif
      
    CALL Problem_SolverPreSolve(solver,err,error,*999)
      
#ifdef TAUPROF
    CALL TAU_STATIC_PHASE_STOP('Pre solve')
    
    CALL TAU_STATIC_PHASE_START('Solve')
#endif
    
    IF(ASSOCIATED(solver%SOLVER_EQUATIONS)) THEN
      !A solver with solver equations.
      CALL PROBLEM_SOLVER_EQUATIONS_SOLVE(solver%SOLVER_EQUATIONS,err,error,*999)
    ELSE
      !Check for other equations.
      IF(ASSOCIATED(solver%CELLML_EQUATIONS)) THEN
        !A solver with CellML equations.
        CALL Problem_CellMLEquationsSolve(solver%CELLML_EQUATIONS,err,error,*999)
      ELSEIF(SOLVER%SOLVE_TYPE==SOLVER_GEOMETRIC_TRANSFORMATION_TYPE) THEN
        CALL Problem_SolverGeometricTransformationSolve(SOLVER%geometricTransformationSolver,err,error,*999)
      ELSE
        !Do nothing now. 
        !CALL FlagError("Solver does not have any equations associated.",err,error,*999)
      ENDIF
    ENDIF

#ifdef TAUPROF
    CALL TAU_STATIC_PHASE_STOP('Solve')
      
    CALL TAU_STATIC_PHASE_START('Post solve')
#endif
    
    CALL Problem_SolverPostSolve(solver,err,error,*999)
    
#ifdef TAUPROF
    CALL TAU_STATIC_PHASE_STOP('Post solve')
#endif
      
    EXITS("Problem_SolverSolve")
    RETURN
999 ERRORSEXITS("Problem_SolverSolve",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SolverSolve

  !
  !================================================================================================================================
  !

  !>Destroy the solvers for a problem. \see OpenCMISS::cmfe_Problem_SolversDestroy
  SUBROUTINE PROBLEM_SOLVERS_DESTROY(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to destroy the solvers for.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables

    ENTERS("PROBLEM_SOLVERS_DESTROY",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      IF(ASSOCIATED(PROBLEM%CONTROL_LOOP)) THEN        
        CALL CONTROL_LOOP_SOLVERS_DESTROY(PROBLEM%CONTROL_LOOP,err,error,*999)
      ELSE
        CALL FlagError("Problem control loop is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_SOLVERS_DESTROY")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVERS_DESTROY",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVERS_DESTROY

  !
  !================================================================================================================================
  !

  !>Set boundary conditions for solver equations according to the analytic equations. \see OPENCMISS_CMISSProblemSolverEquationsBoundaryConditionsAnalytic
  SUBROUTINE Problem_SolverEquationsBoundaryConditionsAnalytic(SOLVER_EQUATIONS,err,error,*)

    !Argument variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS !<A pointer to the solver equations to get the boundary conditions for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equations_set_idx
    TYPE(BOUNDARY_CONDITIONS_TYPE), POINTER :: BOUNDARY_CONDITIONS
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET

    ENTERS("Problem_SolverEquationsBoundaryConditionsAnalytic",err,error,*999)

    IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
      IF(SOLVER_EQUATIONS%SOLVER_EQUATIONS_FINISHED) THEN
        BOUNDARY_CONDITIONS=>SOLVER_EQUATIONS%BOUNDARY_CONDITIONS
        IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
          SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
          IF(ASSOCIATED(SOLVER_MAPPING)) THEN
            DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
              EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
              IF(ASSOCIATED(EQUATIONS_SET)) THEN
                CALL EQUATIONS_SET_BOUNDARY_CONDITIONS_ANALYTIC(EQUATIONS_SET,BOUNDARY_CONDITIONS,err,error,*999)
              ELSE
                CALL FlagError("Equations set is not associated for index "//TRIM(NumberToVString(equations_set_idx,"*", &
                  & err,error))//".",err,error,*999)
              ENDIF
            ENDDO
          ELSE
            CALL FlagError("Solver equations solver mapping is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Solver equations boundary conditions are not associated.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Solver equations has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF

    EXITS("Problem_SolverEquationsBoundaryConditionsAnalytic")
    RETURN
999 ERRORS("Problem_SolverEquationsBoundaryConditionsAnalytic",err,error)
    EXITS("Problem_SolverEquationsBoundaryConditionsAnalytic")
    RETURN 1

  END SUBROUTINE Problem_SolverEquationsBoundaryConditionsAnalytic

  !
  !================================================================================================================================
  !

  !>Finish the creation of the solver equations for the problem. \see OpenCMISS::cmfe_Problem_SolverEquationsCreateFinish
  SUBROUTINE PROBLEM_SOLVER_EQUATIONS_CREATE_FINISH(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to finish the solver equations for
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO

    ENTERS("PROBLEM_SOLVER_EQUATIONS_CREATE_FINISH",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN      
      !Initialise the problem setup information
      CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
      PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE
      PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_FINISH_ACTION
      !Finish problem specific startup
      CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
      !Finalise the problem setup information
      CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
      
    EXITS("PROBLEM_SOLVER_EQUATIONS_CREATE_FINISH")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVER_EQUATIONS_CREATE_FINISH",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVER_EQUATIONS_CREATE_FINISH
  
  !
  !================================================================================================================================
  !

  !>Start the creation of solver equations for a problem. \see OpenCMISS::cmfe_Problem_SolverEquationsCreateStart
  !>The default values of the SOLVER attributes are:
  !>- SOLVE_TYPE: 1 (SOLVER_LINEAR_TYPE)
  !>- OUTPUT_TYPE: 0 (SOLVER_NO_OUTPUT)
  !>- SPARSITY_TYPE: 1 (SOLVER_SPARSE_MATRICES)
  SUBROUTINE PROBLEM_SOLVER_EQUATIONS_CREATE_START(PROBLEM,err,error,*)

    !Argument variablesg
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to start the creation of the solver equations for.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(PROBLEM_SETUP_TYPE) :: PROBLEM_SETUP_INFO

    ENTERS("PROBLEM_SOLVER_EQUATIONS_CREATE_START",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      !Initialise the problem setup information
      CALL PROBLEM_SETUP_INITIALISE(PROBLEM_SETUP_INFO,err,error,*999)
      PROBLEM_SETUP_INFO%SETUP_TYPE=PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE
      PROBLEM_SETUP_INFO%ACTION_TYPE=PROBLEM_SETUP_START_ACTION
      !Start the problem specific control setup
      CALL PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INFO,err,error,*999)
      !Finalise the problem setup information
      CALL PROBLEM_SETUP_FINALISE(PROBLEM_SETUP_INFO,err,error,*999)
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_SOLVER_EQUATIONS_CREATE_START")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVER_EQUATIONS_CREATE_START",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVER_EQUATIONS_CREATE_START

  !
  !================================================================================================================================
  !

  !!TODO: this should be removed - just call the solver equations destroy directly???
  
  !>Destroy the solver equations for a problem. \see OpenCMISS::cmfe_Problem_SolverEquationsDestroy
  SUBROUTINE PROBLEM_SOLVER_EQUATIONS_DESTROY(PROBLEM,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to destroy the solver equations for.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP

    ENTERS("PROBLEM_SOLVER_EQUATIONS_DESTROY",err,error,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      CONTROL_LOOP=>PROBLEM%CONTROL_LOOP
      IF(ASSOCIATED(CONTROL_LOOP)) THEN
        CALL CONTROL_LOOP_SOLVER_EQUATIONS_DESTROY(CONTROL_LOOP,err,error,*999)
      ELSE
        CALL FlagError("Problem control loop is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF
       
    EXITS("PROBLEM_SOLVER_EQUATIONS_DESTROY")
    RETURN
999 ERRORSEXITS("PROBLEM_SOLVER_EQUATIONS_DESTROY",err,error)
    RETURN 1
  END SUBROUTINE PROBLEM_SOLVER_EQUATIONS_DESTROY
  
  !
  !================================================================================================================================
  !

  !>Solves geometric transformation for a field 
  SUBROUTINE Problem_SolverGeometricTransformationSolve(geometricTransformationSolver,err,error,*) !\todo: Add rotation operations.
    
   !Argument variables
    TYPE(GeometricTransformationSolverType), POINTER :: GeometricTransformationSolver !<A pointer to the geometric transformation solver to solve
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: fieldVariable
    TYPE(SOLVER_TYPE), POINTER :: solver
    TYPE(SOLVERS_TYPE), POINTER :: solvers
    TYPE(CONTROL_LOOP_TYPE), POINTER :: controlLoop
    TYPE(CONTROL_LOOP_LOAD_INCREMENT_TYPE), POINTER :: loadIncrementLoop
    TYPE(CONTROL_LOOP_SIMPLE_TYPE), POINTER :: simpleLoop
    TYPE(CONTROL_LOOP_FIXED_TYPE), POINTER :: fixedLoop
    TYPE(CONTROL_LOOP_WHILE_TYPE), POINTER :: whileLoop
    INTEGER(INTG) :: componentIdx,versionIdx,derivativeIdx,nodeIdx,noGeomComp
    INTEGER(INTG) :: localNodeNumber,userNodeNumber,incrementIdx,iterationNumber
    REAL(DP) :: nodalParameters(3),nodalParametersTrans(3),transformationMatrix(4,4)
    TYPE(DOMAIN_TYPE), POINTER :: domain
    TYPE(DOMAIN_NODES_TYPE), POINTER :: domainNodes
    LOGICAL :: transformBC=.FALSE.,sameBases=.TRUE.
    
    ENTERS("Problem_SolverGeometricTransformationSolve",err,error,*999) 
    
    IF(ASSOCIATED(geometricTransformationSolver)) THEN
      IF(ASSOCIATED(geometricTransformationSolver%field)) THEN
        fieldVariable=>geometricTransformationSolver%field%VARIABLE_TYPE_MAP(geometricTransformationSolver%fieldVariableType)%PTR
        IF(ASSOCIATED(fieldVariable%PARAMETER_SETS%SET_TYPE(FIELD_BOUNDARY_CONDITIONS_SET_TYPE)%PTR)) transformBC=.TRUE. !if the BC is defined on the field variable to be transformed
        noGeomComp=SIZE(geometricTransformationSolver%transformationMatrices,1)-1 ! Number of geometric components
        !**********************************************************************************************************************
        !Determine iteration/load increment number 
        IF(geometricTransformationSolver%numberOfIncrements>1) THEN
          solver=>geometricTransformationSolver%solver
          IF(ASSOCIATED(solver)) THEN
            solvers=>solver%SOLVERS
            IF(ASSOCIATED(solvers)) THEN
              controlLoop=>solvers%CONTROL_LOOP
              IF(ASSOCIATED(controlLoop)) THEN
                SELECT CASE(controlLoop%LOOP_TYPE)
                CASE(PROBLEM_CONTROL_SIMPLE_TYPE)
                  simpleLoop=>controlLoop%SIMPLE_LOOP
                  IF(ASSOCIATED(simpleLoop)) THEN
                    iterationNumber=1
                  ELSE
                    CALL FlagError("Simple loop is not associated.",err,error,*999)
                  ENDIF
                CASE(PROBLEM_CONTROL_FIXED_LOOP_TYPE)
                  fixedLoop=>controlLoop%FIXED_LOOP
                  IF(ASSOCIATED(fixedLoop)) THEN
                    iterationNumber=fixedLoop%ITERATION_NUMBER
                  ELSE
                    CALL FlagError("Fixed loop is not associated.",err,error,*999)
                  ENDIF
                CASE(PROBLEM_CONTROL_TIME_LOOP_TYPE)
                  CALL FlagError("Geometric transformation for time loop is not implemented.",err,error,*999)
                CASE(PROBLEM_CONTROL_WHILE_LOOP_TYPE)
                  whileLoop=>controlLoop%WHILE_LOOP
                  IF(ASSOCIATED(whileLoop)) THEN
                    iterationNumber=whileLoop%ITERATION_NUMBER
                  ELSE
                    CALL FlagError("Simple loop is not associated.",err,error,*999)
                  ENDIF
                CASE(PROBLEM_CONTROL_LOAD_INCREMENT_LOOP_TYPE)
                  loadIncrementLoop=>controlLoop%LOAD_INCREMENT_LOOP
                  IF(ASSOCIATED(loadIncrementLoop)) THEN
                    iterationNumber=loadIncrementLoop%ITERATION_NUMBER
                  ELSE
                    CALL FlagError("Load increment loop is not associated.",err,error,*999)
                  ENDIF
                END SELECT
                IF(iterationNumber>geometricTransformationSolver%numberOfIncrements) THEN
                  !If load increment is not specified for that iteration, loop around
                  incrementIdx=MOD(iterationNumber-1,geometricTransformationSolver%numberOfIncrements)+1
                ELSE
                  incrementIdx=iterationNumber !If load increment is specified for that iteration, use that load increment
                ENDIF
              ELSE
                CALL FlagError("Control loop is not associated.",err,error,*999)
              ENDIF
            ELSE
              CALL FlagError("Solvers is not associated.",err,error,*999)
            ENDIF
          ELSE
            CALL FlagError("Solver is not associated.",err,error,*999)
          ENDIF
        ELSE
          incrementIdx=1
        ENDIF
        !Determine the transformation matrix to use
        IF(geometricTransformationSolver%arbitraryPath .OR. geometricTransformationSolver%numberOfIncrements==1) THEN
          transformationMatrix(1:noGeomComp+1,1:noGeomComp+1)=geometricTransformationSolver%transformationMatrices &
            & (1:noGeomComp+1,1:noGeomComp+1,incrementIdx)
        ELSE !If need to scale transformation matrix (i.e. transformation applied through several load increment.)
          IF(incrementIdx==1) THEN ! 1st load increment, rotation is applied
            transformationMatrix(1:noGeomComp,1:noGeomComp)=geometricTransformationSolver%transformationMatrices &
              & (1:noGeomComp,1:noGeomComp,1)
          ELSE !No rotation operation in any other load increments
            DO componentIdx=1,noGeomComp
              transformationMatrix(componentIdx,componentIdx)=1.0_DP
            ENDDO !componentIdx
          ENDIF
          !Translation is scaled for every load increment 
          IF(ALLOCATED(geometricTransformationSolver%scalings)) THEN
            transformationMatrix(1:noGeomComp,noGeomComp+1)=geometricTransformationSolver%transformationMatrices &
              & (1:noGeomComp,noGeomComp+1,1)*geometricTransformationSolver%scalings(incrementIdx)
          ELSE !if no scaling just take 1/numberOfIncrements as scaling
            transformationMatrix(1:noGeomComp,noGeomComp+1)=geometricTransformationSolver%transformationMatrices &
              & (1:noGeomComp,noGeomComp+1,1)/geometricTransformationSolver%numberOfIncrements
          ENDIF
        ENDIF
        !**********************************************************************************************************************
        ! Transform the field
        ! Determine if the all components have the same mesh components/ bases
        DO componentIdx=1,noGeomComp-1
          IF(fieldVariable%COMPONENTS(componentIdx)%MESH_COMPONENT_NUMBER/= &
            & fieldVariable%COMPONENTS(componentIdx+1)%MESH_COMPONENT_NUMBER) sameBases=.FALSE.
        ENDDO
        IF(sameBases) THEN
          domain=>fieldVariable%COMPONENTS(1)%DOMAIN !Use the 1st component domain since they are the same for all components
          IF(ASSOCIATED(domain)) THEN
            domainNodes=>domain%TOPOLOGY%NODES
            DO nodeIdx=1,domainNodes%NUMBER_OF_NODES
              localNodeNumber=domainNodes%NODES(nodeIdx)%LOCAL_NUMBER
              userNodeNumber=domainNodes%NODES(nodeIdx)%USER_NUMBER
              DO derivativeIdx=1,domainNodes%NODES(nodeIdx)%NUMBER_OF_DERIVATIVES
                DO versionIdx=1,domainNodes%NODES(nodeIdx)%DERIVATIVES(derivativeIdx)%numberOfVersions
                  DO componentIdx=1,noGeomComp !Get all component for a nodal derivative
                    CALL FIELD_PARAMETER_SET_GET_NODE(geometricTransformationSolver%field,geometricTransformationSolver% &
                      & fieldVariableType,FIELD_VALUES_SET_TYPE,versionIdx,derivativeIdx,userNodeNumber,componentIdx, &
                      & nodalParameters(componentIdx),err,error,*999)
                  ENDDO !componentIdx
                  !Rotate the nodal parameters
                  userNodeNumber=domainNodes%NODES(nodeIdx)%USER_NUMBER
                  nodalParametersTrans(1:noGeomComp)=MATMUL(transformationMatrix(1:noGeomComp,1:noGeomComp), &
                    & nodalParameters(1:noGeomComp))
                  DO componentIdx=1,noGeomComp !Update all component for a nodal derivative
                    CALL FIELD_PARAMETER_SET_UPDATE_NODE(geometricTransformationSolver%field,geometricTransformationSolver% &
                      & fieldVariableType,FIELD_VALUES_SET_TYPE,versionIdx,derivativeIdx,userNodeNumber,componentIdx, &
                      & nodalParametersTrans(componentIdx),err,error,*999)
                    IF(derivativeIdx==1) THEN ! Translate nodal coordinate
                      CALL FIELD_PARAMETER_SET_ADD_NODE(geometricTransformationSolver%field,geometricTransformationSolver% &
                        & fieldVariableType,FIELD_VALUES_SET_TYPE,versionIdx,derivativeIdx,userNodeNumber,componentIdx, &
                        & transformationMatrix(componentIdx,1+noGeomComp),err,error,*999)
                    ENDIF !derivativeIdx==1
                    IF(transformBC) THEN
                      CALL FIELD_PARAMETER_SET_UPDATE_NODE(geometricTransformationSolver%field,geometricTransformationSolver% &
                        & fieldVariableType,FIELD_BOUNDARY_CONDITIONS_SET_TYPE,versionIdx,derivativeIdx,userNodeNumber, &
                        & componentIdx,nodalParametersTrans(componentIdx),err,error,*999)
                      IF(derivativeIdx==1) THEN ! Translate nodal coordinate for BC
                        CALL FIELD_PARAMETER_SET_ADD_NODE(geometricTransformationSolver%field,geometricTransformationSolver% &
                          & fieldVariableType,FIELD_BOUNDARY_CONDITIONS_SET_TYPE,versionIdx,derivativeIdx,userNodeNumber, &
                          & componentIdx,transformationMatrix(componentIdx,1+noGeomComp),err,error,*999)
                      ENDIF !derivativeIdx==1
                    ENDIF !transformBC
                  ENDDO !componentIdx
                ENDDO !versionIdx
              ENDDO !derivativeIdx
            ENDDO !nodeIdx
          ELSE
            CALL FlagError("Domain is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Transformation for different component bases not implemented.",err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("The field of geometric transformation solver is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Geometric transformation solver is not associated.",err,error,*999)
    ENDIF
      
    EXITS("Problem_SolverGeometricTransformationSolve")
    RETURN
999 ERRORSEXITS("Problem_SolverGeometricTransformationSolve",err,error)
    RETURN 1
  END SUBROUTINE Problem_SolverGeometricTransformationSolve

  !
  !================================================================================================================================
  !

  !>Monitors the problem nonlinear solve
  SUBROUTINE Problem_SolverNonlinearMonitor(solver,iterationNumber,residualNorm,err,error,*)

    !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: solver !<A pointer to the solver to monitor
    INTEGER(INTG), INTENT(IN) :: iterationNumber !<The number of iterations
    REAL(DP), INTENT(IN) :: residualNorm !<The residual norm
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: interfaceConditionIdx
    TYPE(SOLVERS_TYPE), POINTER :: solvers
    TYPE(CONTROL_LOOP_TYPE), POINTER :: controlLoop
    TYPE(PROBLEM_TYPE), POINTER :: problem
    TYPE(NONLINEAR_SOLVER_TYPE), POINTER :: nonlinearSolver
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: solverEquations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: solverMapping
    TYPE(INTERFACE_CONDITION_TYPE), POINTER :: interfaceCondition
    TYPE(INTERFACE_TYPE), POINTER :: interface
    LOGICAL :: reproject
    TYPE(VARYING_STRING) :: localError
    
    ENTERS("Problem_SolverNonlinearMonitor",err,error,*998)
    
    IF(ASSOCIATED(solver)) THEN
      solvers=>solver%SOLVERS
      IF(ASSOCIATED(solvers)) THEN
        controlLoop=>solvers%CONTROL_LOOP
        IF(ASSOCIATED(controlLoop)) THEN
          problem=>controlLoop%PROBLEM
          IF(ASSOCIATED(problem)) THEN
            IF(.NOT.ALLOCATED(problem%specification)) THEN
              CALL FlagError("Problem specification is not allocated.",err,error,*999)
            ELSE IF(SIZE(problem%specification,1)<1) THEN
              CALL FlagError("Problem specification must have at least one entry.",err,error,*999)
            END IF
            SELECT CASE(problem%SPECIFICATION(1))
            CASE(PROBLEM_ELASTICITY_CLASS)
              IF(SIZE(problem%specification,1)/=3) THEN
                CALL FlagError("Problem specification must have three entries for an elasticity problem.",err,error,*999)
              END IF
              SELECT CASE(problem%SPECIFICATION(2))
              CASE(PROBLEM_LINEAR_ELASTICITY_TYPE,PROBLEM_FINITE_ELASTICITY_TYPE)
                !Output meshes at iterations
                IF(solver%SOLVE_TYPE==SOLVER_NONLINEAR_TYPE) THEN
                  nonlinearSolver=>solver%NONLINEAR_SOLVER
                  IF(ASSOCIATED(nonlinearSolver)) THEN
                    CALL Problem_SolverNewtonFieldsOutput(solver,iterationNumber,err,error,*999)
                  ENDIF
                ENDIF
              CASE(PROBLEM_LINEAR_ELASTICITY_CONTACT_TYPE,PROBLEM_FINITE_ELASTICITY_CONTACT_TYPE)
                SELECT CASE(problem%SPECIFICATION(3))
                CASE(PROBLEM_LE_CONTACT_TRANSFORM_SUBTYPE,PROBLEM_FE_CONTACT_TRANSFORM_SUBTYPE) !Reproject at iteration 0 before the nonlinear solve to update xi location since the field is transformed.
                  IF(iterationNumber==0) THEN
                    reproject=.TRUE.
                  ELSE
                    reproject=.FALSE.
                  ENDIF
                CASE(PROBLEM_LE_CONTACT_TRANSFORM_REPROJECT_SUBTYPE,PROBLEM_LE_CONTACT_REPROJECT_SUBTYPE, &
                    & PROBLEM_FE_CONTACT_TRANSFORM_REPROJECT_SUBTYPE,PROBLEM_FE_CONTACT_REPROJECT_SUBTYPE)
                  reproject=.TRUE.
                CASE DEFAULT
                  localError="The problem subtype of "//TRIM(NumberToVString(problem%SPECIFICATION(3),"*",err,error))//" &
                    & is invalid."
                  CALL FlagError(localError,err,error,*999)
                END SELECT
                IF(Reproject) THEN
                  solverEquations=>solver%SOLVER_EQUATIONS
                  IF(ASSOCIATED(solverEquations)) THEN
                    solverMapping=>solverEquations%SOLVER_MAPPING
                    IF(ASSOCIATED(solverMapping)) THEN
                      DO interfaceConditionIdx=1,solverMapping%NUMBER_OF_INTERFACE_CONDITIONS
                        interfaceCondition=>solverMapping%INTERFACE_CONDITIONS(interfaceConditionIdx)%PTR
                        IF(ASSOCIATED(interfaceCondition)) THEN
                          IF(interfaceCondition%OPERATOR==INTERFACE_CONDITION_FLS_CONTACT_REPROJECT_OPERATOR .OR. &
                              & interfaceCondition%OPERATOR==INTERFACE_CONDITION_FLS_CONTACT_OPERATOR) THEN !Only reproject for contact operator
                            IF(interfaceCondition%integrationType==INTERFACE_CONDITION_DATA_POINTS_INTEGRATION) THEN !Only reproject for data point interpolated field
                              interface=>interfaceCondition%INTERFACE
                              IF(ASSOCIATED(interface)) THEN
                                CALL WriteString(GENERAL_OUTPUT_TYPE,"**************** Reproject! ****************",err,error,*999)
                                CALL InterfacePointsConnectivity_DataReprojection(interface,interfaceCondition,err,error,*999)
                                CALL INTERFACE_CONDITION_ASSEMBLE(interfaceCondition,err,error,*999)
                              ELSE
                                CALL FlagError("Interface is not associated for nonlinear solver equations mapping.", &
                                  & err,error,*999)
                              ENDIF
                            ENDIF
                          ENDIF
                        ELSE
                          CALL FlagError("Interface condition is not associated for nonlinear solver equations mapping.", &
                            & err,error,*999)
                        ENDIF
                      ENDDO !interfaceConditionIdx
                    ELSE
                      CALL FlagError("Nonlinear solver equations mapping is not associated.",err,error,*999)
                    ENDIF
                  ELSE
                    CALL FlagError("Nonlinear solver equations is not associated.",err,error,*999)
                  ENDIF
                ENDIF !Reproject
                !Output meshes at iterations
                IF(solver%SOLVE_TYPE==SOLVER_NONLINEAR_TYPE) THEN
                  nonlinearSolver=>solver%NONLINEAR_SOLVER
                  IF(ASSOCIATED(nonlinearSolver)) THEN
                    CALL Problem_SolverNewtonFieldsOutput(solver,iterationNumber,err,error,*999)
                  ENDIF
                ENDIF
              CASE DEFAULT
                localError="The problem type of "//TRIM(NumberToVString(problem%SPECIFICATION(2),"*",err,error))//" &
                  & is invalid."
                CALL FlagError(localError,err,error,*999)
              END SELECT
            CASE(PROBLEM_BIOELECTRICS_CLASS,PROBLEM_FLUID_MECHANICS_CLASS,PROBLEM_ELECTROMAGNETICS_CLASS, &
                & PROBLEM_CLASSICAL_FIELD_CLASS,PROBLEM_FITTING_CLASS,PROBLEM_MODAL_CLASS,PROBLEM_MULTI_PHYSICS_CLASS)
              !Do nothing???
            CASE DEFAULT
              localError="The problem class of "//TRIM(NumberToVString(problem%SPECIFICATION(1),"*",err,error))//" &
                & is invalid."
              CALL FlagError(localError,err,error,*999)
            END SELECT
          ELSE
            CALL FlagError("Problem is not associated.",err,error,*999)
          ENDIF
        ELSE
          CALL FlagError("Problem control loop is not associated.",err,error,*999)
        ENDIF
      ENDIF
      !Nonlinear solve monitor--progress output if required
      IF(solver%SOLVE_TYPE==SOLVER_NONLINEAR_TYPE) THEN
        nonlinearSolver=>solver%NONLINEAR_SOLVER
        IF(ASSOCIATED(nonlinearSolver)) THEN
          CALL SOLVER_NONLINEAR_MONITOR(nonlinearSolver,iterationNumber,residualNorm,err,error,*999)
        ELSE
          CALL FlagError("Nonlinear solver is not associated.",err,error,*999)
        ENDIF
      ELSE
        localError="Invalid solve type. The solve type of "//TRIM(NumberToVString(solver%SOLVE_TYPE,"*",err,error))// &
          & " does not correspond to a nonlinear solver."
        CALL FlagError(localError,err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver is not associated.",err,error,*999)
    ENDIF
    
    EXITS("Problem_SolverNonlinearMonitor")
    RETURN
999 NULLIFY(SOLVER)
998 ERRORSEXITS("Problem_SolverNonlinearMonitor",err,error)
    RETURN 1
  END SUBROUTINE Problem_SolverNonlinearMonitor
  
  !
  !================================================================================================================================
  !

  !> Output fields at Newton iterations. This is in temporarily for debug output. It may be removed at a later date.
  SUBROUTINE Problem_SolverNewtonFieldsOutput(solver,iterationNumber,err,error,*)

    !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: solver !<A pointer to solver to output the fields for
    INTEGER(INTG), INTENT(IN) :: iterationNumber !<Iteration number
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: equationsSetIdx,load_step
    LOGICAL :: dirExists
    TYPE(REGION_TYPE), POINTER :: region !<A pointer to region to output the fields for
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: solverMapping 
    TYPE(FIELDS_TYPE), POINTER :: fields
    TYPE(VARYING_STRING) :: fileName,method,directory
    
    INTEGER(INTG) :: interfaceConditionIdx, interfaceElementNumber, dataPointIdx, globalDataPointNumber, coupledMeshElementNumber, &
      & coupledMeshFaceLineNumber, coupledMeshIdx,component
    TYPE(INTERFACE_TYPE), POINTER :: interface !<A pointer to the interface 
    TYPE(INTERFACE_CONDITION_TYPE), POINTER :: interfaceCondition
    TYPE(InterfacePointsConnectivityType), POINTER :: pointsConnectivity !<A pointer to the interface points connectivity
    TYPE(FIELD_TYPE), POINTER :: coupledMeshDependentField
    TYPE(FIELD_INTERPOLATION_PARAMETERS_PTR_TYPE), POINTER :: interpolationParameters(:)
    TYPE(FIELD_INTERPOLATED_POINT_PTR_TYPE), POINTER :: interpolatedPoints(:)
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: interpolatedPoint
    TYPE(DecompositionElementDataPointsType), POINTER :: decompositionElementData !<A pointer to the decomposition data point topology
    TYPE(DataPointsType), POINTER :: interfaceDatapoints
    TYPE(DataProjectionType), POINTER :: dataProjection

    TYPE(PROBLEM_TYPE), POINTER :: problem

    INTEGER(INTG) :: IUNIT
    CHARACTER(LEN=100) :: filenameOutput,groupname

    TYPE(VARYING_STRING) :: fileToCheck,localError
    LOGICAL :: fileExists
    INTEGER(INTG) :: firstIterationNumber, solve_call, max_solve_calls

    ENTERS("Problem_SolverNewtonFieldsOutput",err,error,*999)
    
    IF(ASSOCIATED(solver%SOLVER_EQUATIONS))THEN
      solverMapping=>SOLVER%SOLVER_EQUATIONS%SOLVER_MAPPING
      problem=>solver%SOLVERS%CONTROL_LOOP%PROBLEM

      IF(.NOT.ALLOCATED(problem%SPECIFICATION)) THEN
        CALL FlagError("Problem specification is not allocated.",err,error,*999)
      ELSE IF(SIZE(problem%SPECIFICATION,1)<1) THEN
        CALL FlagError("Problem specification must have at least one entry.",err,error,*999)
      END IF
      SELECT CASE(problem%SPECIFICATION(1))
      CASE(PROBLEM_ELASTICITY_CLASS)
        IF(SIZE(problem%specification,1)/=3) THEN
          CALL FlagError("Problem specification must have three entries for an elasticity problem.",err,error,*999)
        END IF
        SELECT CASE(problem%SPECIFICATION(2))
        CASE(PROBLEM_LINEAR_ELASTICITY_TYPE,PROBLEM_FINITE_ELASTICITY_TYPE,PROBLEM_LINEAR_ELASTICITY_CONTACT_TYPE, &
          & PROBLEM_FINITE_ELASTICITY_CONTACT_TYPE)

          !This is not how diagnostics should be used
          ! IF(DIAGNOSTICS1) THEN          
          !   directory="results_iter/"
          !   INQUIRE(FILE=CHAR(directory),EXIST=dirExists)
          !   IF(.NOT.dirExists) THEN
          !     CALL SYSTEM(CHAR("mkdir "//directory))
          !   ENDIF

          !   ! Find how many times the problem solve command has been issued.
          !   max_solve_calls=100
          !   coupledMeshIdx=1
          !   load_step=1
          !   firstIterationNumber=0
          !   DO solve_call=1,max_solve_calls
          !     fileToCheck=directory// &
          !       & "mesh"//TRIM(NumberToVString(coupledMeshIdx,"*",err,error))// &
          !       & "_solveCall"//TRIM(NumberToVString(solve_call,"*",err,error))// &
          !       & "_load"//TRIM(NumberToVString(load_step,"*",err,error))// &
          !       & "_iter"//TRIM(NumberToVString(firstIterationNumber,"*",err,error))//".part0.exnode"
          !     INQUIRE(FILE=CHAR(fileToCheck),EXIST=fileExists)
          !     IF(.NOT.fileExists) THEN
          !       EXIT
          !     ENDIF
          !   ENDDO

          !   load_step=solver%SOLVERS%CONTROL_LOOP%LOAD_INCREMENT_LOOP%ITERATION_NUMBER

          !   IF((iterationNumber > 0).OR.(load_step > 1))THEN
          !     solve_call = solve_call - 1
          !   ENDIF

          !   WRITE(*,'(1X,''SolveCall: '',I4)') solve_call
          !   WRITE(*,'(1X,''  LoadStep: '',I4)') load_step
          !   WRITE(*,'(1X,''    Iteration: '',I4)') iterationNumber

          !   DO equationsSetIdx=1,solverMapping%NUMBER_OF_EQUATIONS_SETS
          !     region=>solverMapping%EQUATIONS_SETS(equationsSetIdx)%PTR%REGION
          !     IF(ASSOCIATED(region))THEN
          !       NULLIFY(fields)
          !       fields=>region%FIELDS
          !       fileName=directory//"mesh"//TRIM(NumberToVString(equationsSetIdx,"*",err,error))// &
          !         & "_solveCall"//TRIM(NumberToVString(solve_call,"*",err,error))// &
          !         & "_load"//TRIM(NumberToVString(load_step,"*",err,error))// &
          !         & "_iter"//TRIM(NumberToVString(iterationNumber,"*",err,error))
          !       method="FORTRAN"
          !       CALL FIELD_IO_ELEMENTS_EXPORT(fields,fileName,method,err,error,*999)
          !       CALL FIELD_IO_NODES_EXPORT(fields,fileName,method,err,error,*999)
          !     ELSE
          !       CALL FlagError("Region is not associated.",err,error,*999)
          !     ENDIF
          !   ENDDO
          ! ENDIF

        CASE DEFAULT
          localError="The problem type of "//TRIM(NumberToVString(problem%SPECIFICATION(2),"*",err,error))//" &
            & is invalid."
          CALL FlagError(localError,err,error,*999)
        END SELECT
      CASE(PROBLEM_BIOELECTRICS_CLASS,PROBLEM_FLUID_MECHANICS_CLASS,PROBLEM_ELECTROMAGNETICS_CLASS, &
          & PROBLEM_CLASSICAL_FIELD_CLASS,PROBLEM_FITTING_CLASS,PROBLEM_MODAL_CLASS,PROBLEM_MULTI_PHYSICS_CLASS)
        !Do nothing???
      CASE DEFAULT
        localError="The problem class of "//TRIM(NumberToVString(problem%SPECIFICATION(1),"*",err,error))//" &
          & is invalid."
        CALL FlagError(localError,err,error,*999)
      END SELECT

      SELECT CASE(problem%SPECIFICATION(1))
      CASE(PROBLEM_ELASTICITY_CLASS)
        SELECT CASE(problem%SPECIFICATION(2))
        CASE(PROBLEM_LINEAR_ELASTICITY_TYPE,PROBLEM_FINITE_ELASTICITY_TYPE)
          ! Pass
        CASE(PROBLEM_LINEAR_ELASTICITY_CONTACT_TYPE,PROBLEM_FINITE_ELASTICITY_CONTACT_TYPE)

          IF(DIAGNOSTICS1) THEN
            IUNIT = 300
            DO interfaceConditionIdx=1,solverMapping%NUMBER_OF_INTERFACE_CONDITIONS
              interfaceCondition=>solverMapping%INTERFACE_CONDITIONS(interfaceConditionIdx)%PTR
              interface=>solverMapping%INTERFACE_CONDITIONS(interfaceConditionIdx)%PTR%interface
              pointsConnectivity=>interface%pointsConnectivity
              interfaceDatapoints=>pointsConnectivity%dataPoints
              IF(ASSOCIATED(pointsConnectivity)) THEN
                DO coupledMeshIdx=1,interface%NUMBER_OF_COUPLED_MESHES
                  filenameOutput=directory//"PointsConnectivity"//TRIM(NumberToVString(coupledMeshIdx,"*",err,error))// &
                    & "_solveCall"//TRIM(NumberToVString(solve_call,"*",err,error))// &
                    & "_load"//TRIM(NumberToVString(load_step,"*",err,error))// &
                    & "_iter"//TRIM(NumberToVString(iterationNumber,"*",err,error))//".exdata"
                  OPEN(UNIT=IUNIT,FILE=filenameOutput,STATUS="UNKNOWN",ACTION="WRITE",IOSTAT=ERR)
                  groupname="PointsConnectivity"//TRIM(NumberToVString(coupledMeshIdx,"*",err,error))
                  WRITE(IUNIT,'( '' Group name: '',A)') groupname
                  WRITE(IUNIT,'(1X,''#Fields=4'')')
                  WRITE(IUNIT,'(1X,''1) coordinates, coordinate, rectangular cartesian, #Components=3'')')
                  WRITE(IUNIT,'(1X,''  x.  Value index= 1, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''  y.  Value index= 2, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''  z.  Value index= 3, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''2) error, field, rectangular cartesian, #Components=3'')')
                  WRITE(IUNIT,'(1X,''  x.  Value index= 4, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''  y.  Value index= 5, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''  z.  Value index= 6, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''3) projectedCoordinate, field, rectangular cartesian, #Components=3'')')
                  WRITE(IUNIT,'(1X,''  x.  Value index= 7, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''  y.  Value index= 8, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''  z.  Value index= 9, #Derivatives=0'')')
                  WRITE(IUNIT,'(1X,''4) exitTag, field, rectangular cartesian, #Components=1'')')
                  WRITE(IUNIT,'(1X,''  tag.  Value index= 10, #Derivatives=0'')')
                  coupledMeshDependentField=>interfaceCondition%DEPENDENT%EQUATIONS_SETS(coupledMeshIdx)%PTR% &
                    & DEPENDENT%DEPENDENT_FIELD
                  NULLIFY(interpolationParameters)
                  CALL FIELD_INTERPOLATION_PARAMETERS_INITIALISE(coupledMeshDependentField,interpolationParameters,err,error, &
                    & *999,FIELD_GEOMETRIC_COMPONENTS_TYPE)
                  NULLIFY(interpolatedPoints)
                  CALL FIELD_INTERPOLATED_POINTS_INITIALISE(interpolationParameters,interpolatedPoints,err,error,*999, &
                    & FIELD_GEOMETRIC_COMPONENTS_TYPE)
                  interpolatedPoint=>interpolatedPoints(FIELD_U_VARIABLE_TYPE)%PTR
                  dataProjection=>interfaceDatapoints%dataProjections%dataProjections(coupledMeshIdx+1)%PTR
                  DO interfaceElementNumber=1,SIZE(pointsConnectivity%coupledElements,1)
                    decompositionElementData=>interfaceCondition%LAGRANGE%LAGRANGE_FIELD%DECOMPOSITION%TOPOLOGY%dataPoints% &
                      & elementDataPoint(interfaceElementNumber)
                    DO dataPointIdx=1,decompositionElementData%numberOfProjectedData
                      globalDataPointNumber=decompositionElementData%dataIndices(dataPointIdx)%globalNumber
                      WRITE(IUNIT,'(1X,''Node:'',I4)') globalDataPointNumber
                      DO component=1,3
                        WRITE(IUNIT,'(1X,3E25.15)') interfaceDatapoints%dataPoints(globalDataPointNumber)%position(component)
                      ENDDO !component
                      coupledMeshElementNumber=pointsConnectivity%pointsConnectivity(globalDataPointNumber,coupledMeshIdx)% &
                        & coupledMeshElementNumber
                      coupledMeshFaceLineNumber=coupledMeshDependentField%DECOMPOSITION%TOPOLOGY%ELEMENTS% &
                        & ELEMENTS(coupledMeshElementNumber)% &
                        & ELEMENT_FACES(pointsConnectivity%pointsConnectivity(globalDataPointNumber,coupledMeshIdx)% &
                        & elementLineFaceNumber)
                      CALL FIELD_INTERPOLATION_PARAMETERS_FACE_GET(FIELD_VALUES_SET_TYPE,coupledMeshFaceLineNumber, &
                        & interpolationParameters(FIELD_U_VARIABLE_TYPE)%PTR,err,error,*999,FIELD_GEOMETRIC_COMPONENTS_TYPE)
                      CALL FIELD_INTERPOLATE_XI(NO_PART_DERIV,pointsConnectivity%pointsConnectivity(globalDataPointNumber, &
                        & coupledMeshIdx)%reducedXi(:),interpolatedPoint,err,error,*999,FIELD_GEOMETRIC_COMPONENTS_TYPE) !Interpolate contact data points on each surface
                      DO component=1,3
                        WRITE(IUNIT,'(1X,3E25.15)') interpolatedPoint%VALUES(component,NO_PART_DERIV) - &
                          & interfaceDatapoints%dataPoints(globalDataPointNumber)%position(component)
                      ENDDO !component
                      DO component=1,3
                        WRITE(IUNIT,'(1X,3E25.15)') interpolatedPoint%VALUES(component,NO_PART_DERIV)
                      ENDDO !component
                      WRITE(IUNIT,'(1X,I2)') dataProjection%dataProjectionResults(globalDataPointNumber)%exitTag
                    ENDDO !dataPointIdx
                  ENDDO !interfaceElementNumber
                  CALL FIELD_INTERPOLATION_PARAMETERS_FINALISE(interpolationParameters,err,error,*999)
                  CALL FIELD_INTERPOLATED_POINTS_FINALISE(interpolatedPoints,err,error,*999)
                  OPEN(UNIT=IUNIT)
                ENDDO !coupledMeshIdx
              ENDIF
            ENDDO !interfaceConditionIdx
          ENDIF

        CASE DEFAULT
          localError="The problem type of "//TRIM(NumberToVString(problem%SPECIFICATION(2),"*",err,error))//" &
            & is invalid."
          CALL FlagError(localError,err,error,*999)
        END SELECT
      CASE(PROBLEM_BIOELECTRICS_CLASS,PROBLEM_FLUID_MECHANICS_CLASS,PROBLEM_ELECTROMAGNETICS_CLASS, &
          & PROBLEM_CLASSICAL_FIELD_CLASS,PROBLEM_FITTING_CLASS,PROBLEM_MODAL_CLASS,PROBLEM_MULTI_PHYSICS_CLASS)
        !Do nothing???
      CASE DEFAULT
        localError="The problem class of "//TRIM(NumberToVString(problem%SPECIFICATION(1),"*",err,error))//" &
          & is invalid."
        CALL FlagError(localError,err,error,*999)
      END SELECT

    ELSE
      CALL FlagError("Solver equations is not associated.",err,error,*999)
    ENDIF
    
    EXITS("Problem_SolverNewtonFieldsOutput")
    RETURN
999 ERRORSEXITS("Problem_SolverNewtonFieldsOutput",err,error)
    RETURN 1
  END SUBROUTINE Problem_SolverNewtonFieldsOutput
  
  !
  !================================================================================================================================
  !

  !>Monitors the problem optimiser solve
  SUBROUTINE Problem_SolverOptimiserMonitor(solver,err,error,*)

    !Argument variables
    TYPE(SOLVER_TYPE), POINTER :: solver !<A pointer to the solver to monitor
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: controlLoop
    TYPE(PROBLEM_TYPE), POINTER :: problem
    TYPE(OptimiserSolverType), POINTER :: optimiserSolver
    TYPE(VARYING_STRING) :: localError
    
    ENTERS("Problem_SolverOptimiserMonitor",err,error,*999)
    
    IF(.NOT.ASSOCIATED(solver)) CALL FlagError("Solver is not associated.",err,error,*999)
    
    NULLIFY(controlLoop)
    CALL Solver_ControlLoopGet(solver,controlLoop,err,error,*999)
    NULLIFY(problem)
    CALL ControlLoop_ProblemGet(controlLoop,problem,err,error,*999)
    
    !IF(.NOT.ALLOCATED(problem%specification)) CALL FlagError("Problem specification is not allocated.",err,error,*999)
    !IF(SIZE(problem%specification,1)<1) CALL FlagError("Problem specification must have at least one entry.",err,error,*999)

    !SELECT CASE(problem%specification(1))
    !CASE DEFAULT
    !  localError="The problem class of "//TRIM(NumberToVString(problem%specification(1),"*",err,error))//" is invalid."
    !  CALL FlagError(localError,err,error,*999)
    !END SELECT

    !Optimiser solve monitor--progress output if required
    IF(solver%SOLVE_TYPE==SOLVER_OPTIMISER_TYPE) THEN
      optimiserSolver=>solver%optimiserSolver
      IF(.NOT.ASSOCIATED(optimiserSolver)) CALL FlagError("Solver optimiser solver is not associated.",err,error,*999)
      CALL Solver_OptimiserMonitor(optimiserSolver,err,error,*999)
    ELSE
      localError="Invalid solve type. The solve type of "//TRIM(NumberToVString(solver%SOLVE_TYPE,"*",err,error))// &
        & " does not correspond to an optimiser solver."
      CALL FlagError(localError,err,error,*999)
    ENDIF
    
    EXITS("Problem_SolverOptimiserMonitor")
    RETURN
999 ERRORSEXITS("Problem_SolverOptimiserMonitor",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SolverOptimiserMonitor
  
  !
  !================================================================================================================================
  !

  !>Gets the problem specification array for a problem identified by a pointer. \see OpenCMISS::cmfe_Problem_SpecificationGet
  SUBROUTINE Problem_SpecificationGet(problem,problemSpecification,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: problem !<A pointer to the problem to get the specification for.
    INTEGER(INTG), INTENT(INOUT) :: problemSpecification(:) !<On return, The problem specifcation array. Must be allocated on entry.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    INTEGER(INTG) :: specificationLength

    ENTERS("Problem_SpecificationGet",err,error,*999)

    IF(ASSOCIATED(problem)) THEN
      IF(problem%problem_finished) THEN
        IF(.NOT.ALLOCATED(problem%specification)) THEN
          CALL FlagError("Problem specification is not allocated.",err,error,*999)
        END IF
        specificationLength=SIZE(problem%specification,1)
        IF(SIZE(problemSpecification,1)>=specificationLength) THEN
          problemSpecification(1:specificationLength)=problem%specification(1:specificationLength)
        ELSE
          CALL FlagError("The problem specification size is "//TRIM(NumberToVstring(specificationLength,"*",err,error))// &
            & " but the input array only has size "//TRIM(NumberToVstring(SIZE(problemSpecification,1),"*",err,error))//".", &
            & err,error,*999)
        ENDIF
      ELSE
        CALL FlagError("Problem has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF

    EXITS("Problem_SpecificationGet")
    RETURN
999 ERRORSEXITS("Problem_SpecificationGet",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SpecificationGet

  !
  !================================================================================================================================
  !

  !>Sets the problem specification
  SUBROUTINE Problem_SpecificationSet(problem,problemSpecification,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: problem !<A pointer to the problem to set the specification for.
    INTEGER(INTG), INTENT(IN) :: problemSpecification(:) !<The problem specification array to set.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: localError
    INTEGER(INTG) :: problemClass

    ENTERS("Problem_SpecificationSet",err,error,*999)

    IF(ASSOCIATED(problem)) THEN
      IF(problem%problem_finished) THEN
        CALL FlagError("Problem has been finished.",err,error,*999)
      ELSE
        IF(SIZE(problemSpecification,1)<1) THEN
          CALL FlagError("Problem specification array must have one or more entries.",err,error,*999)
        ENDIF
        problemClass=problemSpecification(1)
        SELECT CASE(problemClass)
        CASE(PROBLEM_ELASTICITY_CLASS)
          CALL Elasticity_ProblemSpecificationSet(problem,problemSpecification,err,error,*999)
        CASE(PROBLEM_FLUID_MECHANICS_CLASS)
          CALL FluidMechanics_ProblemSpecificationSet(problem,problemSpecification,err,error,*999)
        CASE(PROBLEM_ELECTROMAGNETICS_CLASS)
          CALL FlagError("Not implemented.",err,error,*999)
        CASE(PROBLEM_CLASSICAL_FIELD_CLASS)
          CALL ClassicalField_ProblemSpecificationSet(problem,problemSpecification,err,error,*999)
        CASE(PROBLEM_BIOELECTRICS_CLASS)
          CALL Bioelectric_ProblemSpecificationSet(problem,problemSpecification,err,error,*999)
        CASE(PROBLEM_MODAL_CLASS)
          CALL FlagError("Not implemented.",err,error,*999)
        CASE(PROBLEM_FITTING_CLASS)
          CALL Fitting_ProblemSpecificationSet(problem,problemSpecification,err,error,*999)
        CASE(PROBLEM_OPTIMISATION_CLASS)
          CALL FlagError("Not implemented.",err,error,*999)
        CASE(PROBLEM_MULTI_PHYSICS_CLASS)
          CALL MultiPhysics_ProblemSpecificationSet(problem,problemSpecification,err,error,*999)
        CASE DEFAULT
          localError="The first problems specification of "//TRIM(NumberToVstring(problemClass,"*",err,error))//" is not valid."
          CALL FlagError(localError,err,error,*999)
        END SELECT
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF

    EXITS("Problem_SpecificationSet")
    RETURN
999 ERRORSEXITS("Problem_SpecificationSet",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SpecificationSet

  !
  !================================================================================================================================
  !

  !>Gets the size of the problem specification array for a problem identified by a pointer. \see OpenCMISS::cmfe_Problem_SpecificationSizeGet
  SUBROUTINE Problem_SpecificationSizeGet(problem,specificationSize,err,error,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: problem !<A pointer to the problem to get the specification for.
    INTEGER(INTG), INTENT(OUT) :: specificationSize !<On return, the size of the problem specifcation array.
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables

    ENTERS("Problem_SpecificationSizeGet",err,error,*999)

    specificationSize=0
    IF(ASSOCIATED(problem)) THEN
      IF(problem%problem_finished) THEN
        IF(.NOT.ALLOCATED(problem%specification)) THEN
          CALL FlagError("Problem specification is not allocated.",err,error,*999)
        END IF
        specificationSize=SIZE(problem%specification,1)
      ELSE
        CALL FlagError("Problem has not been finished.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Problem is not associated.",err,error,*999)
    ENDIF

    EXITS("Problem_SpecificationSizeGet")
    RETURN
999 ERRORSEXITS("Problem_SpecificationSizeGet",err,error)
    RETURN 1
    
  END SUBROUTINE Problem_SpecificationSizeGet

  !
  !================================================================================================================================
  !

  !>Finalises all problems and deallocates all memory.
  SUBROUTINE PROBLEMS_FINALISE(err,error,*)

    !Argument variables
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables

    ENTERS("PROBLEMS_FINALISE",err,error,*999)

    DO WHILE(PROBLEMS%NUMBER_OF_PROBLEMS>0)
      CALL PROBLEM_DESTROY(PROBLEMS%PROBLEMS(1)%PTR,err,error,*999)
    ENDDO !problem_idx
    
    EXITS("PROBLEMS_FINALISE")
    RETURN
999 ERRORSEXITS("PROBLEMS_FINALISE",err,error)
    RETURN 1   
  END SUBROUTINE PROBLEMS_FINALISE

  !
  !================================================================================================================================
  !

  !>Intialises all problems.
  SUBROUTINE PROBLEMS_INITIALISE(err,error,*)

    !Argument variables
    INTEGER(INTG), INTENT(OUT) :: err !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables

    ENTERS("PROBLEMS_INITIALISE",err,error,*999)

    PROBLEMS%NUMBER_OF_PROBLEMS=0
    NULLIFY(PROBLEMS%PROBLEMS)
    
    EXITS("PROBLEMS_INITIALISE")
    RETURN
999 ERRORSEXITS("PROBLEMS_INITIALISE",err,error)
    RETURN 1   
  END SUBROUTINE PROBLEMS_INITIALISE
  
  !
  !================================================================================================================================
  !

  
END MODULE PROBLEM_ROUTINES

!
!================================================================================================================================
!

!>Called from the PETSc SNES solvers to evaluate the Jacobian for a Newton like nonlinear solver
SUBROUTINE Problem_SolverJacobianEvaluatePetsc(snes,x,A,B,ctx,err)

  USE BaseRoutines
  USE CmissPetscTypes
  USE DistributedMatrixVector
  USE ISO_VARYING_STRING
  USE KINDS
  USE PROBLEM_ROUTINES
  USE SOLVER_ROUTINES
  USE SOLVER_MATRICES_ROUTINES
  USE STRINGS
  USE TYPES

  IMPLICIT NONE
 
  !Argument variables
  TYPE(PetscSnesType), INTENT(INOUT) :: snes !<The PETSc snes
  TYPE(PetscVecType), INTENT(INOUT) :: X !<The PETSc x Vec
  TYPE(PetscMatType), INTENT(INOUT) :: A !<The PETSc A Mat
  TYPE(PetscMatType), INTENT(INOUT) :: B !<The PETSc B Mat
  TYPE(SOLVER_TYPE), POINTER :: ctx !<The passed through context
  INTEGER(INTG), INTENT(INOUT) :: err !<The error code
  !Local Variables
  INTEGER(INTG) :: dummyErr
  TYPE(DistributedVectorType), POINTER :: solverVector
  TYPE(NEWTON_SOLVER_TYPE), POINTER :: newtonSolver
  TYPE(NONLINEAR_SOLVER_TYPE), POINTER :: nonlinearSolver
  TYPE(QUASI_NEWTON_SOLVER_TYPE), POINTER :: quasiNewtonSolver
  TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: solverEquations
  TYPE(SOLVER_MATRICES_TYPE), POINTER :: solverMatrices
  TYPE(SOLVER_MATRIX_TYPE), POINTER :: solverMatrix
  TYPE(VARYING_STRING) :: dummyError,error,localError

  IF(ASSOCIATED(ctx)) THEN
    solverEquations=>ctx%SOLVER_EQUATIONS
    IF(ASSOCIATED(solverEquations)) THEN
      solverMatrices=>solverEquations%SOLVER_MATRICES
      IF(ASSOCIATED(solverMatrices)) THEN
        IF(solverMatrices%NUMBER_OF_MATRICES==1) THEN
          solverMatrix=>solverMatrices%matrices(1)%ptr
          IF(ASSOCIATED(solverMatrix)) THEN
            solverVector=>solverMatrix%SOLVER_VECTOR
            IF(ASSOCIATED(solverVector)) THEN
              CALL DistributedVector_OverrideSetOn(solverVector,x,err,error,*999)
              
              CALL PROBLEM_SOLVER_JACOBIAN_EVALUATE(ctx,err,error,*999)
              
              CALL DistributedVector_OverrideSetOff(solverVector,err,error,*999)
            ELSE
              CALL FlagError("Solver vector is not associated.",err,error,*998)              
            ENDIF
          ELSE
            CALL FlagError("Solver matrix is not associated.",err,error,*998)
          ENDIF
        ELSE
          localError="The number of solver matrices of "// &
            & TRIM(NumberToVString(solverMatrices%NUMBER_OF_MATRICES,"*",err,error))// &
            & " is invalid. There should be 1 solver matrix."
          CALL FlagError(localError,err,error,*998)
        ENDIF
      ELSE
        CALL FlagError("Solver equations solver matrices is not associated.",err,error,*998)
      ENDIF
    ELSE
      CALL FlagError("Solver solver equations is not associated.",err,error,*998)
    ENDIF
!!TODO: move this to PROBLEM_SOLVER_JACOBIAN_EVALUATE or elsewhere?
    nonlinearSolver=>ctx%NONLINEAR_SOLVER
    IF(ASSOCIATED(nonlinearSolver)) THEN
      SELECT CASE(nonlinearSolver%NONLINEAR_SOLVE_TYPE)
      CASE(SOLVER_NONLINEAR_NEWTON)
        newtonSolver=>nonlinearSolver%NEWTON_SOLVER
        IF(ASSOCIATED(newtonSolver)) THEN
          newtonSolver%TOTAL_NUMBER_OF_JACOBIAN_EVALUATIONS=newtonSolver%TOTAL_NUMBER_OF_JACOBIAN_EVALUATIONS+1
        ELSE
          CALL FlagError("Nonlinear solver Newton solver is not associated.",err,error,*998)
        ENDIF
      CASE(SOLVER_NONLINEAR_QUASI_NEWTON)
        quasiNewtonSolver=>nonlinearSolver%QUASI_NEWTON_SOLVER
        IF(ASSOCIATED(quasiNewtonSolver)) THEN
          quasiNewtonSolver%TOTAL_NUMBER_OF_JACOBIAN_EVALUATIONS=quasiNewtonSolver%TOTAL_NUMBER_OF_JACOBIAN_EVALUATIONS+1
        ELSE
          CALL FlagError("Nonlinear solver Quasi-Newton solver is not associated.",err,error,*998)
        ENDIF
      CASE DEFAULT
        !Do nothing?
      END SELECT      
    ELSE
      CALL FlagError("Solver nonlinear solver is not associated.",err,error,*998)
    ENDIF
  ELSE
    CALL FlagError("Solver context is not associated.",err,error,*998)
  ENDIF
  
  RETURN
999 CALL DistributedVector_OverrideSetOff(solverVector,dummyErr,dummyError,*998)
998 CALL WriteError(err,error,*997)
997 CALL FlagWarning("Error evaluating nonlinear Jacobian.",err,error,*996)
996 RETURN 
END SUBROUTINE Problem_SolverJacobianEvaluatePetsc

!
!================================================================================================================================
!

!>Called from the PETSc SNES solvers to evaluate the Jacobian for a Newton like nonlinear solver using PETSc's FD Jacobian
!>calculation.
SUBROUTINE Problem_SolverJacobianFDCalculatePetsc(snes,x,A,B,ctx,err)

  USE BaseRoutines
  USE CmissPetsc
  USE CmissPetscTypes
  USE DistributedMatrixVector
  USE ISO_VARYING_STRING
  USE KINDS
  USE PROBLEM_ROUTINES
  USE SOLVER_MATRICES_ROUTINES
  USE SOLVER_ROUTINES
  USE STRINGS
  USE TYPES
  

  IMPLICIT NONE

  !Argument variables
  TYPE(PetscSnesType), INTENT(INOUT) :: snes !<The PETSc SNES
  TYPE(PetscVecType), INTENT(INOUT) :: x !<The PETSc x Vec
  TYPE(PetscMatType), INTENT(INOUT) :: A !<The PETSc A Mat
  TYPE(PetscMatType), INTENT(INOUT) :: B !<The PETSc B Mat
  TYPE(SOLVER_TYPE), POINTER :: ctx !<The passed through context
  INTEGER(INTG), INTENT(INOUT) :: err !<The error code
  !Local Variables
  INTEGER(INTG) :: dummyErr
  TYPE(NEWTON_SOLVER_TYPE), POINTER :: newtonSolver
  TYPE(NONLINEAR_SOLVER_TYPE), POINTER :: nonlinearSolver
  TYPE(NEWTON_LINESEARCH_SOLVER_TYPE), POINTER :: linesearchSolver
  TYPE(QUASI_NEWTON_SOLVER_TYPE), POINTER :: quasiNewtonSolver
  TYPE(QUASI_NEWTON_LINESEARCH_SOLVER_TYPE), POINTER :: quasiNewtonLinesearchSolver
  TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: solverEquations
  TYPE(SOLVER_MATRICES_TYPE), POINTER :: solverMatrices
  TYPE(SOLVER_MATRIX_TYPE), POINTER :: solverMatrix
  TYPE(PetscMatFDColoringType), POINTER :: jacobianMatFDColoring
  TYPE(VARYING_STRING) :: dummyError,error,localError

  IF(ASSOCIATED(ctx)) THEN
    nonlinearSolver=>ctx%NONLINEAR_SOLVER
    IF(ASSOCIATED(nonlinearSolver)) THEN
      solverEquations=>ctx%SOLVER_EQUATIONS
      IF(ASSOCIATED(solverEquations)) THEN
        solverMatrices=>solverEquations%SOLVER_MATRICES
        IF(ASSOCIATED(solverMatrices)) THEN
          IF(solverMatrices%NUMBER_OF_MATRICES==1) THEN
            solverMatrix=>solverMatrices%matrices(1)%ptr
            IF(ASSOCIATED(solverMatrix)) THEN
              SELECT CASE(solverEquations%sparsityType)
              CASE(SOLVER_SPARSE_MATRICES)
                SELECT CASE(nonlinearSolver%NONLINEAR_SOLVE_TYPE)
                CASE(SOLVER_NONLINEAR_NEWTON)
                  newtonSolver=>nonlinearSolver%NEWTON_SOLVER
                  IF(ASSOCIATED(newtonSolver)) THEN
                    linesearchSolver=>newtonSolver%LINESEARCH_SOLVER
                    IF(ASSOCIATED(linesearchSolver)) THEN
                      jacobianMatFDColoring=>linesearchSolver%jacobianMatFDColoring
                    ELSE
                      CALL FlagError("Newton solver linesearch solver is not associated.",err,error,*999)
                    ENDIF
                  ELSE
                    CALL FlagError("Nonlinear solver Newton solver is not associated.",err,error,*999)
                  ENDIF
                CASE(SOLVER_NONLINEAR_QUASI_NEWTON)
                  quasiNewtonSolver=>nonlinearSolver%QUASI_NEWTON_SOLVER
                  IF(ASSOCIATED(quasiNewtonSolver)) THEN
                    quasiNewtonLinesearchSolver=>quasiNewtonSolver%LINESEARCH_SOLVER
                    IF(ASSOCIATED(quasiNewtonLinesearchSolver)) THEN
                      jacobianMatFDColoring=>quasiNewtonLinesearchSolver%jacobianMatFDColoring
                    ELSE
                      CALL FlagError("Quasi-Newton solver linesearch solver is not associated.",err,error,*999)
                    ENDIF
                  ELSE
                    CALL FlagError("Nonlinear solver quasi Newton solver is not associated.",err,error,*999)
                  ENDIF
                CASE DEFAULT
                  localError="The nonlinear solver type of "// &
                    & TRIM(NumberToVString(nonlinearSolver%NONLINEAR_SOLVE_TYPE,"*",err,error))// &
                    & " is invalid."
                  CALL FlagError(localError,err,error,*999)
                END SELECT                
                IF(ASSOCIATED(jacobianMatFDColoring)) THEN
                  CALL Petsc_SnesComputeJacobianDefaultColor(snes,x,A,B,jacobianMatFDColoring,err,error,*999)
                ELSE
                  CALL FlagError("Linesearch solver FD colouring is not associated.",err,error,*998)
                ENDIF
              CASE(SOLVER_FULL_MATRICES)
                CALL Petsc_SnesComputeJacobianDefault(snes,x,A,B,ctx,err,error,*999)
              CASE DEFAULT
                localError="The specified solver equations sparsity type of "// &
                  & TRIM(NumberToVString(solverEquations%sparsityType,"*",err,error))//" is invalid."
                CALL FlagError(localError,err,error,*999)
              END SELECT
              IF(ctx%outputType>=SOLVER_MATRIX_OUTPUT) THEN
                CALL DistributedMatrix_OverrideSetOn(solverMatrices%matrices(1)%ptr%matrix,A,err,error,*999)
                CALL SOLVER_MATRICES_OUTPUT(GENERAL_OUTPUT_TYPE,SOLVER_MATRICES_JACOBIAN_ONLY,solverMatrices,err,error,*998)
                CALL DistributedMatrix_OverrideSetOff(solverMatrices%matrices(1)%ptr%matrix,err,error,*999)
              ENDIF
            ELSE
              CALL FlagError("Solver matrix is not associated.",err,error,*998)
            ENDIF
          ELSE
            localError="The number of solver matrices of "// &
              & TRIM(NumberToVString(solverMatrices%NUMBER_OF_MATRICES,"*",err,error))// &
              & " is invalid. There should be 1 solver matrix."
            CALL FlagError(localError,err,error,*998)
          ENDIF
        ELSE
          CALL FlagError("Solver equations solver matrices is not associated.",err,error,*998)
        ENDIF
      ELSE
        CALL FlagError("Solver solver equations is not associated.",err,error,*998)
      ENDIF
    ELSE
      CALL FlagError("Nonlinear solver is not associated.",err,error,*998)
    ENDIF
  ELSE
    CALL FlagError("Solver context is not associated.",err,error,*998)
  ENDIF

  RETURN
999 CALL DistributedMatrix_OverrideSetOff(solverMatrix%matrix,dummyErr,dummyError,*998)
998 CALL WriteError(err,error,*997)
997 CALL FlagWarning("Error evaluating nonlinear Jacobian.",err,error,*996)
996 RETURN
  
END SUBROUTINE Problem_SolverJacobianFDCalculatePetsc

!
!================================================================================================================================
!

!>Called from the PETSc TAO solvers to evaluate the objective for an optimiser solver
SUBROUTINE Problem_SolverObjectiveEvaluatePetsc(tao,x,f,ctx,err)

  USE BaseRoutines
  USE CmissPetscTypes
  USE DistributedMatrixVector
  USE ISO_VARYING_STRING
  USE KINDS
  USE PROBLEM_ROUTINES
  USE SOLVER_ROUTINES
  USE STRINGS
  USE TYPES

  IMPLICIT NONE
  
  !Argument variables
  TYPE(PetscTaoType), INTENT(INOUT) :: tao !<The PETSc tao type
  TYPE(PetscVecType), INTENT(INOUT) :: x !<The PETSc x Vec type
  REAL(DP), INTENT(OUT) :: f !<On exit, the evaluated objective
  TYPE(SOLVER_TYPE), POINTER :: ctx !<The passed through context
  INTEGER(INTG), INTENT(INOUT) :: err !<The error code
  !Local Variables
  INTEGER(INTG) :: dummyErr
  TYPE(DistributedVectorType), POINTER :: solverVector
  TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: solverEquations
  TYPE(SOLVER_MATRICES_TYPE), POINTER :: solverMatrices
  TYPE(SOLVER_MATRIX_TYPE), POINTER :: solverMatrix
  TYPE(VARYING_STRING) :: dummyError,error,localError

  IF(.NOT.ASSOCIATED(ctx)) CALL FlagError("Solver context is not associated.",err,error,*997)
  IF(.NOT.ASSOCIATED(ctx%optimiserSolver)) CALL FlagError("Solver optimiser solver is not associated.",err,error,*997)
  IF(.NOT.ASSOCIATED(ctx%SOLVER_EQUATIONS)) CALL FlagError("Solver equations is not associated.",err,error,*997)
  
  solverEquations=>ctx%SOLVER_EQUATIONS
  solverMatrices=>solverEquations%SOLVER_MATRICES
  IF(.NOT.ASSOCIATED(solverMatrices)) CALL FlagError("Solver equations solver matrices is not associated.",err,error,*997)
  IF(solverMatrices%NUMBER_OF_MATRICES/=1) THEN
    localError="The number of solver matrices of "//TRIM(NumberToVString(solverMatrices%NUMBER_OF_MATRICES,"*",err,error))// &
      & " is invalid. There should be 1 solver matrix."
    CALL FlagError(localError,err,error,*997)          
  ENDIF
  solverMatrix=>solverMatrices%matrices(1)%ptr
  IF(.NOT.ASSOCIATED(solverMatrix)) CALL FlagError("Solver matrix is not associated.",err,error,*997)
  solverVector=>solverMatrix%SOLVER_VECTOR
  IF(.NOT.ASSOCIATED(solverVector)) CALL FlagError("Solver vector is not associated.",err,error,*997)

  CALL DistributedVector_OverrideSetOn(solverVector,x,err,error,*999)
    
  !CALL Problem_SolverObjectiveEvaluate(ctx,err,error,*999)

  f=0.0_DP
                    
  CALL DistributedVector_OverrideSetOff(solverVector,err,error,*999)

!!TODO: move this to PROBLEM_SOLVER_RESIDUAL_EVALUATE or elsewhere?
  !optimiserSolver%totalNumberOfObjectiveEvaluations=optimiserSolver%totalNumberOfFunctionEvaluations+1
  
  RETURN
999 CALL DistributedVector_OverrideSetOff(solverVector,dummyErr,dummyError,*998)  
998 CALL WriteError(err,error,*997)
997 CALL FlagWarning("Error evaluating optimiser objective.",err,error,*996)
996 RETURN

END SUBROUTINE Problem_SolverObjectiveEvaluatePetsc

!
!================================================================================================================================
!

!>Called from the PETSc SNES solvers to evaluate the residual for a Newton like nonlinear solver
SUBROUTINE Problem_SolverResidualEvaluatePetsc(snes,x,f,ctx,err)

  USE BaseRoutines
  USE CmissPetscTypes
  USE DistributedMatrixVector
  USE ISO_VARYING_STRING
  USE KINDS
  USE PROBLEM_ROUTINES
  USE SOLVER_ROUTINES
  USE STRINGS
  USE TYPES

  IMPLICIT NONE
  
  !Argument variables
  TYPE(PetscSnesType), INTENT(INOUT) :: snes !<The PETSc snes type
  TYPE(PetscVecType), INTENT(INOUT) :: x !<The PETSc x Vec type
  TYPE(PetscVecType), INTENT(INOUT) :: f !<The PETSc f Vec type
  TYPE(SOLVER_TYPE), POINTER :: ctx !<The passed through context
  INTEGER(INTG), INTENT(INOUT) :: err !<The error code
  !Local Variables
  INTEGER(INTG) :: dummyErr
  TYPE(DistributedVectorType), POINTER :: residualVector,solverVector
  TYPE(NEWTON_SOLVER_TYPE), POINTER :: newtonSolver
  TYPE(NONLINEAR_SOLVER_TYPE), POINTER :: nonlinearSolver
  TYPE(QUASI_NEWTON_SOLVER_TYPE), POINTER :: quasiNewtonSolver
  TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: solverEquations
  TYPE(SOLVER_MATRICES_TYPE), POINTER :: solverMatrices
  TYPE(SOLVER_MATRIX_TYPE), POINTER :: solverMatrix
  TYPE(VARYING_STRING) :: dummyError,error,localError

  IF(ASSOCIATED(ctx)) THEN
    nonlinearSolver=>ctx%NONLINEAR_SOLVER
    IF(ASSOCIATED(nonlinearSolver)) THEN
      newtonSolver=>nonlinearSolver%NEWTON_SOLVER
      IF(ASSOCIATED(newtonSolver)) THEN
        solverEquations=>ctx%SOLVER_EQUATIONS
        IF(ASSOCIATED(solverEquations)) THEN
          solverMatrices=>solverEquations%SOLVER_MATRICES
          IF(ASSOCIATED(solverMatrices)) THEN
            IF(solverMatrices%NUMBER_OF_MATRICES==1) THEN
              solverMatrix=>solverMatrices%MATRICES(1)%PTR
              IF(ASSOCIATED(solverMatrix)) THEN
                solverVector=>solverMatrix%SOLVER_VECTOR
                IF(ASSOCIATED(solverVector)) THEN
                  residualVector=>solverMatrices%RESIDUAL
                  IF(ASSOCIATED(residualVector)) THEN
                    CALL DistributedVector_OverrideSetOn(solverVector,X,err,error,*999)
                    CALL DistributedVector_OverrideSetOn(residualVector,F,err,error,*999)                
                    
                    CALL PROBLEM_SOLVER_RESIDUAL_EVALUATE(ctx,err,error,*999)
                    
                    CALL DistributedVector_OverrideSetOff(solverVector,err,error,*999)
                    CALL DistributedVector_OverrideSetOff(residualVector,err,error,*999)                
                  ELSE
                    CALL FlagError("Residual vector is not associated.",err,error,*997)                
                  ENDIF
                ELSE
                  CALL FlagError("Solver vector is not associated.",err,error,*997)
                ENDIF
              ELSE
                
              ENDIF
            ELSE
              localError="The number of solver matrices of "// &
                & TRIM(NumberToVString(solverMatrices%NUMBER_OF_MATRICES,"*",err,error))// &
                & " is invalid. There should be 1 solver matrix."
              CALL FlagError(localError,err,error,*997)          
            ENDIF
          ELSE
            CALL FlagError("Solver equations solver matrices is not associated.",err,error,*997)
          ENDIF
        ELSE
          CALL FlagError("Solver solver equations is not associated.",err,error,*997)
        ENDIF
!!TODO: move this to PROBLEM_SOLVER_RESIDUAL_EVALUATE or elsewhere?
        nonLinearSolver=>ctx%NONLINEAR_SOLVER
        IF(ASSOCIATED(nonlinearSolver)) THEN
          SELECT CASE(nonLinearSolver%NONLINEAR_SOLVE_TYPE)
          CASE(SOLVER_NONLINEAR_NEWTON)
            newtonSolver=>nonlinearSolver%NEWTON_SOLVER
            IF(ASSOCIATED(newtonSolver)) THEN
              newtonSolver%TOTAL_NUMBER_OF_FUNCTION_EVALUATIONS=newtonSolver%TOTAL_NUMBER_OF_FUNCTION_EVALUATIONS+1
            ELSE
              CALL FlagError("Newton solver is not associated.",err,error,*997)
            ENDIF
          CASE(SOLVER_NONLINEAR_QUASI_NEWTON)
            quasiNewtonSolver=>nonLinearSolver%QUASI_NEWTON_SOLVER
            IF(ASSOCIATED(quasiNewtonSolver)) THEN
              quasiNewtonSolver%TOTAL_NUMBER_OF_FUNCTION_EVALUATIONS=quasiNewtonSolver%TOTAL_NUMBER_OF_FUNCTION_EVALUATIONS+1
            ELSE
              CALL FlagError("Quasi-Newton solver is not associated.",err,error,*997)
            ENDIF
          CASE DEFAULT
            !Do nothing?
          END SELECT
        ELSE
          CALL FlagError("Nonlinear solve is not associated.", err,error,*997)
        ENDIF
      ELSE
        CALL FlagError("Nonlinear solver Newton solver is not associated.",err,error,*997)
      ENDIF
    ELSE
      CALL FlagError("Solver nonlinear solver is not associated.",err,error,*997)
    ENDIF
  ELSE
    CALL FlagError("Solver context is not associated.",err,error,*997)
  ENDIF
  
  RETURN
999 CALL DistributedVector_OverrideSetOff(solverVector,dummyErr,dummyError,*998)  
998 CALL DistributedVector_OverrideSetOff(residualVector,dummyErr,dummyError,*997)
997 CALL WriteError(err,error,*996)
996 CALL FlagWarning("Error evaluating nonlinear residual.",err,error,*995)
995 RETURN

END SUBROUTINE Problem_SolverResidualEvaluatePetsc

!
!================================================================================================================================
!

!>Called from the PETSc SNES solvers to test convergence for a Newton like nonlinear solver
SUBROUTINE Problem_SolverConvergenceTestPetsc(snes,iterationNumber,xnorm,gnorm,fnorm,reason,ctx,err)

  USE BaseRoutines
  USE CmissPetsc
  USE CmissPetscTypes
  USE DistributedMatrixVector
  USE INPUT_OUTPUT
  USE KINDS
  USE PROBLEM_ROUTINES
  USE SOLVER_ROUTINES
  USE STRINGS
  USE TYPES
 
  IMPLICIT NONE
  
  !Argument variables
  TYPE(PetscSnesType), INTENT(INOUT) :: snes !<The PETSc SNES type
  INTEGER(INTG), INTENT(INOUT) :: iterationNumber !< The current iteration (1 is the first and is before any Newton step)
  REAL(DP), INTENT(INOUT) :: xnorm !<The 2-norm of current iterate
  REAL(DP), INTENT(INOUT) :: gnorm !<The 2-norm of current step
  REAL(DP), INTENT(INOUT) :: fnorm !<The 2-norm of function
  INTEGER(INTG), INTENT(INOUT) :: reason !<The reason for convergence/divergence
  TYPE(SOLVER_TYPE), POINTER :: ctx !<The passed through context
  INTEGER(INTG), INTENT(INOUT) :: err !<The error code
  !Local Variables
  TYPE(PetscVecType) :: x,f,y,w,g
  TYPE(NEWTON_SOLVER_TYPE), POINTER :: newtonSolver
  TYPE(NONLINEAR_SOLVER_TYPE), POINTER :: nonlinearSolver
  TYPE(QUASI_NEWTON_SOLVER_TYPE), POINTER :: quasiNewtonSolver
  TYPE(PetscSnesLinesearchType) :: lineSearch
  REAL(DP) :: energy,normalisedEnergy
  TYPE(VARYING_STRING) :: error,localError

  IF(ASSOCIATED(ctx)) THEN
    nonlinearSolver=>ctx%NONLINEAR_SOLVER
    IF(ASSOCIATED(nonlinearSolver)) THEN
      SELECT CASE(nonlinearSolver%NONLINEAR_SOLVE_TYPE)
      CASE(SOLVER_NONLINEAR_NEWTON)
        newtonSolver=>nonlinearSolver%NEWTON_SOLVER
        IF(ASSOCIATED(newtonSolver)) THEN 
          reason=PETSC_SNES_CONVERGED_ITERATING
          SELECT CASE(newtonSolver%convergenceTestType)
          CASE(SOLVER_NEWTON_CONVERGENCE_ENERGY_NORM)
            IF(iterationNumber>0) THEN
              CALL Petsc_SnesLineSearchInitialise(lineSearch,err,error,*999)
              CALL Petsc_SnesGetLineSearch(snes,lineSearch,err,error,*999)
              CALL Petsc_VecInitialise(x,err,error,*999)
              CALL Petsc_VecInitialise(f,err,error,*999)
              CALL Petsc_VecInitialise(y,err,error,*999)
              CALL Petsc_VecInitialise(w,err,error,*999)
              CALL Petsc_VecInitialise(g,err,error,*999)
              CALL Petsc_SnesLineSearchGetVecs(lineSearch,x,f,y,w,g,err,error,*999)
              CALL Petsc_VecDot(y,g,energy,err,error,*999)
              IF(iterationNumber==1) THEN
                IF(ABS(energy)<ZERO_TOLERANCE) THEN
                  reason=PETSC_SNES_CONVERGED_FNORM_ABS
                ELSE
                  newtonSolver%convergenceTest%energyFirstIter=energy
                  newtonSolver%convergenceTest%normalisedEnergy=1.0
                ENDIF
              ELSE
                normalisedEnergy=energy/newtonSolver%convergenceTest%energyFirstIter
                newtonSolver%convergenceTest%normalisedEnergy=normalisedEnergy
                IF(ABS(normalisedEnergy)<newtonSolver%ABSOLUTE_TOLERANCE) THEN
                  reason=PETSC_SNES_CONVERGED_FNORM_ABS
                  newtonSolver%convergenceTest%energyFirstIter=0.0_DP
                  newtonSolver%convergenceTest%normalisedEnergy=0.0_DP
                ENDIF
                CALL WriteString(GENERAL_OUTPUT_TYPE,"*********************************************",err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Normalised energy = ",normalisedEnergy,err,error,*999)
                CALL WriteString(GENERAL_OUTPUT_TYPE,"*********************************************",err,error,*999)
              ENDIF
              CALL Petsc_SnesLineSearchFinalise(lineSearch,err,error,*999)
            ENDIF
          CASE(SOLVER_NEWTON_CONVERGENCE_DIFFERENTIATED_RATIO)
            CALL FlagError("Differentiated ratio convergence test not implemented.",err,error,*999)
          CASE DEFAULT
            localError="The specified convergence test type of "//TRIM(NumberToVString( &
              & newtonSolver%convergenceTestType,"*",err,error))//" is invalid."
            CALL FlagError(localError,err,error,*999)
          END SELECT
        ELSE
          CALL FlagError("Nonlinear solver Newton solver is not associated.",err,error,*999)
        ENDIF
      CASE(SOLVER_NONLINEAR_QUASI_NEWTON)
        quasiNewtonSolver=>nonlinearSolver%QUASI_NEWTON_SOLVER
        IF(ASSOCIATED(quasiNewtonSolver)) THEN 
          reason=PETSC_SNES_CONVERGED_ITERATING
          SELECT CASE(quasiNewtonSolver%convergenceTestType)
          CASE(SOLVER_NEWTON_CONVERGENCE_ENERGY_NORM)
            IF(iterationNumber>0) THEN
              CALL Petsc_SnesLineSearchInitialise(lineSearch,err,error,*999)
              CALL Petsc_SnesGetLineSearch(snes,lineSearch,err,error,*999)
              CALL Petsc_VecInitialise(x,err,error,*999)
              CALL Petsc_VecInitialise(f,err,error,*999)
              CALL Petsc_VecInitialise(y,err,error,*999)
              CALL Petsc_VecInitialise(w,err,error,*999)
              CALL Petsc_VecInitialise(g,err,error,*999)
              CALL Petsc_SnesLineSearchGetVecs(lineSearch,x,f,y,w,g,err,error,*999)
              CALL Petsc_VecDot(y,g,energy,err,error,*999)
              IF(iterationNumber==1) THEN
                IF(ABS(energy)<ZERO_TOLERANCE) THEN
                  reason=PETSC_SNES_CONVERGED_FNORM_ABS
                ELSE
                  quasiNewtonSolver%convergenceTest%energyFirstIter=energy
                  quasiNewtonSolver%convergenceTest%normalisedEnergy=1.0
                ENDIF
              ELSE
                normalisedEnergy=energy/quasiNewtonSolver%convergenceTest%energyFirstIter
                quasiNewtonSolver%convergenceTest%normalisedEnergy=normalisedEnergy
                IF(ABS(normalisedEnergy)<quasiNewtonSolver%ABSOLUTE_TOLERANCE) THEN
                  reason=PETSC_SNES_CONVERGED_FNORM_ABS
                  quasiNewtonSolver%convergenceTest%energyFirstIter=0.0_DP
                  quasiNewtonSolver%convergenceTest%normalisedEnergy=0.0_DP
                ENDIF
                CALL WriteString(GENERAL_OUTPUT_TYPE,"*********************************************",err,error,*999)
                CALL WriteStringValue(GENERAL_OUTPUT_TYPE,"Normalised energy = ",normalisedEnergy,err,error,*999)
                CALL WriteString(GENERAL_OUTPUT_TYPE,"*********************************************",err,error,*999)
              ENDIF
              CALL Petsc_SnesLineSearchFinalise(lineSearch,err,error,*999)
            ELSE
              quasiNewtonSolver%convergenceTest%energyFirstIter=0.0_DP
              quasiNewtonSolver%convergenceTest%normalisedEnergy=0.0_DP
            ENDIF
          CASE(SOLVER_NEWTON_CONVERGENCE_DIFFERENTIATED_RATIO)
            CALL FlagError("Differentiated ratio convergence test not implemented.",err,error,*999)
          CASE DEFAULT
            localError="The specified convergence test type of "//TRIM(NumberToVString( &
              & quasiNewtonSolver%convergenceTestType,"*",err,error))//" is invalid."
            CALL FlagError(localError,err,error,*999)
          END SELECT
        ELSE
          CALL FlagError("Nonlinear solver quasi Newton solver is not associated.",err,error,*999)
        ENDIF
      CASE DEFAULT
        !Do nothing?
      END SELECT
    ELSE
      CALL FlagError("Solver nonlinear solver is not associated.",err,error,*999)
    ENDIF
  ELSE
    CALL FlagError("Solver context is not associated.",err,error,*999)
  ENDIF
  
  RETURN
999 CALL WriteError(err,error,*998)
998 CALL FlagWarning("Error in convergence test.",err,error,*997)
997 RETURN    

END SUBROUTINE Problem_SolverConvergenceTestPetsc

!
!================================================================================================================================
!


!>Called from the PETSc TS solvers to solve cellml DAE
SUBROUTINE Problem_SolverDAECellMLRHSPetsc(ts,time,states,rates,ctx,err)

  USE BaseRoutines
  USE CmissPetscTypes
  USE CmissPetsc
  USE PROBLEM_ROUTINES
  USE TYPES

  IMPLICIT NONE

  !Argument variables
  TYPE(PetscTSType), INTENT(INOUT) :: ts !<The PETSc TS type
  REAL(DP), INTENT(INOUT) :: time !<The current time
  TYPE(PetscVecType), INTENT(INOUT) :: states !<current states
  TYPE(PetscVecType), INTENT(INOUT) :: rates !<returned rates
  TYPE(CellMLPETScContextType), POINTER :: ctx !<The passed through context
  INTEGER(INTG), INTENT(INOUT) :: err !<The error code
  !Local Variables
  TYPE(CELLML_TYPE), POINTER :: cellML
  TYPE(SOLVER_TYPE), POINTER :: solver
  TYPE(VARYING_STRING) :: error
  INTEGER(INTG) :: dofIdx
  REAL(DP), POINTER :: stateData(:)

  NULLIFY(stateData)

  IF(ASSOCIATED(ctx)) THEN
    solver=>ctx%solver
    IF(ASSOCIATED(solver)) THEN
      cellML=>ctx%cellml
      IF(ASSOCIATED(cellml)) THEN
        dofIdx=ctx%dofIdx
        !Get the state data
        NULLIFY(stateData)
        CALL Petsc_VecGetArrayReadF90(states,stateData,err,error,*999)
        !Evaluate the CellML model
        CALL Problem_SolverDAECellMLRHSEvaluate(cellML,time,dofIdx,stateData,ctx%rates,err,error,*999)
        !Restore the state data
        CALL Petsc_VecRestoreArrayReadF90(states,stateData,err,error,*999)
        !Set the PETSc rates vector
        CALL Petsc_VecSetValues(rates,SIZE(stateData,1),ctx%ratesIndices,ctx%rates,PETSC_INSERT_VALUES,err,error,*999)
        CALL VecAssemblyBegin(rates,err,error,*999)
        CALL VecAssemblyEnd(rates,err,error,*999)
      ELSE
        CALL FlagError("Context cellml is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Context solver is not associated.",err,error,*999)
    ENDIF 
  ELSE
    CALL FlagError("Context is not associated.",err,error,*999)
  ENDIF
  
  RETURN
999 CALL WriteError(err,error,*998)
998 CALL FlagWarning("Error calling Problem_SolverDAECellMLRHSPetsc routine from PETSc.",err,error,*997)
997 RETURN    

END SUBROUTINE Problem_SolverDAECellMLRHSPetsc


!
!================================================================================================================================
!

!>Called from the PETSc SNES solvers to monitor a nonlinear solver
SUBROUTINE Problem_SolverNonlinearMonitorPETSC(snes,iterationNumber,residualNorm,context,err)

  USE BaseRoutines
  USE CmissPetscTypes
  USE DistributedMatrixVector
  USE ISO_VARYING_STRING
  USE KINDS
  USE PROBLEM_ROUTINES
  USE STRINGS
  USE TYPES

  IMPLICIT NONE
  
  !Argument variables
  TYPE(PetscSnesType), INTENT(INOUT) :: snes !<The PETSc snes type
  INTEGER(INTG), INTENT(INOUT) :: iterationNumber !<The iteration number
  REAL(DP), INTENT(INOUT) :: residualNorm !<The residual norm
  TYPE(SOLVER_TYPE), POINTER :: context !<The passed through context
  INTEGER(INTG), INTENT(INOUT) :: err !<The error code
  !Local Variables
  TYPE(NONLINEAR_SOLVER_TYPE), POINTER :: nonlinearSolver
  TYPE(SOLVER_TYPE), POINTER :: solver
  TYPE(VARYING_STRING) :: error

  IF(ASSOCIATED(context)) THEN
    nonlinearSolver=>context%NONLINEAR_SOLVER
    IF(ASSOCIATED(nonlinearSolver)) THEN
      solver=>nonlinearSolver%SOLVER
      IF(ASSOCIATED(solver)) THEN
        CALL Problem_SolverNonlinearMonitor(solver,iterationNumber,residualNorm,err,error,*999)
      ELSE
        CALL FlagError("Solver is not associated.",err,error,*999)
      ENDIF
    ELSE
      CALL FlagError("Solver nonlinear solver is not associated.",err,error,*999)
    ENDIF
  ELSE
    CALL FlagError("Solver context is not associated.",err,error,*999)
  ENDIF
  
  RETURN

999 CALL WriteError(err,error,*998)
998 CALL FlagWarning("Error evaluating nonlinear residual.",err,error,*997)
997 RETURN    

END SUBROUTINE Problem_SolverNonlinearMonitorPETSC

!
!================================================================================================================================
!

!>Called from the PETSc TAO solvers to monitor an optimiser solver
SUBROUTINE Problem_SolverOptimiserMonitorPETSC(tao,context,err)

  USE BaseRoutines
  USE CmissPetscTypes
  USE ISO_VARYING_STRING
  USE KINDS
  USE PROBLEM_ROUTINES
  USE TYPES

  IMPLICIT NONE
  
  !Argument variables
  TYPE(PetscTaoType), INTENT(INOUT) :: tao !<The PETSc tao type
  TYPE(SOLVER_TYPE), POINTER :: context !<The passed through context (solver)
  INTEGER(INTG), INTENT(INOUT) :: err !<The error code
  !Local Variables
  TYPE(VARYING_STRING) :: error

  IF(.NOT.ASSOCIATED(context)) CALL FlagError("Solver context is not associated.",err,error,*999)
  IF(.NOT.ASSOCIATED(context%optimiserSolver)) CALL FlagError("Solver optimiser solver is not associated.",err,error,*999)
  IF(.NOT.ASSOCIATED(context%optimiserSolver%solver)) CALL FlagError("Solver is not associated.",err,error,*999)
  
  CALL Problem_SolverOptimiserMonitor(context%optimiserSolver%solver,err,error,*999)
  
  RETURN

999 CALL WriteError(err,error,*998)
998 CALL FlagWarning("Error monitoring optimiser.",err,error,*997)
997 RETURN    

END SUBROUTINE Problem_SolverOptimiserMonitorPETSC
