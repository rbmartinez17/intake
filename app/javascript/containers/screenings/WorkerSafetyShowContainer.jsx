import WorkerSafetyShow from 'views/workerSafety/WorkerSafetyShow'
import {
  getAlertValuesSelector,
  getInformationValueSelector,
} from 'selectors/screening/workerSafetyShowSelectors'
import {connect} from 'react-redux'

const mapStateToProps = (state, _ownProps) => (
  {
    safetyAlerts: getAlertValuesSelector(state),
    safetyInformation: getInformationValueSelector(state),
  }
)

const mergeProps = (stateProps, dispatchProps, ownProps) => {
  const {safetyAlerts, safetyInformation} = stateProps
  const {showEdit, toggleMode} = ownProps

  return {safetyAlerts, safetyInformation, showEdit, toggleMode}
}

export default connect(mapStateToProps, null, mergeProps)(WorkerSafetyShow)
