import ContactShow from 'investigations/ContactShow'
import {
  getCommunicationMethodValueSelector,
  getFormattedPeopleSelector,
  getLocationValueSelector,
  getPurposeValueSelector,
  getStatusValueSelector,
} from 'selectors/investigation/contactSelectors'
import {getInvestigationTitleSelector} from 'selectors/investigation/investigationSelectors'
import {push} from 'react-router-redux'
import * as actions from 'actions/contactActions'
import {bindActionCreators} from 'redux'
import {connect} from 'react-redux'

const mapStateToProps = (state, ownProps) => {
  const contact = state.get('contact')
  return {
    communicationMethod: getCommunicationMethodValueSelector(state),
    id: ownProps.params.id,
    investigationId: ownProps.params.investigation_id,
    location: getLocationValueSelector(state),
    note: contact.get('note'),
    pageTitle: `Contact for ${getInvestigationTitleSelector(state)}`,
    people: getFormattedPeopleSelector(state).toJS(),
    purpose: getPurposeValueSelector(state),
    startedAt: contact.get('started_at'),
    status: getStatusValueSelector(state),
  }
}

const mapDispatchToProps = (dispatch, ownProps) => {
  const investigationId = ownProps.params.investigation_id
  const id = ownProps.params.id
  const contactEditPath = `/investigations/${investigationId}/contacts/${id}/edit`
  return {
    onEdit: () => dispatch(push(contactEditPath)),
    actions: bindActionCreators(actions, dispatch),
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ContactShow)
