import COUNTIES from 'enums/Counties'
import Immutable from 'immutable'
import PropTypes from 'prop-types'
import React from 'react'
import nameFormatter from 'utils/nameFormatter'
import {ROLE_TYPE_NON_REPORTER} from 'enums/RoleType'
import {dateRangeFormatter} from 'utils/dateFormatter'

const HistoryCardScreening = ({screening, index}) => {
  const incidentCounty = screening.get('county_name')
  const participants = screening.get('all_people')
  const reporter = screening.get('reporter')
  const assignee = screening.get('assigned_social_worker')
  const nonReporterTypes = Immutable.fromJS(ROLE_TYPE_NON_REPORTER)

  let nonOnlyReporters

  if (participants) {
    nonOnlyReporters = participants.filter((p) => {
      const roles = p.get('roles')
      return roles.some((role) => nonReporterTypes.includes(role)) || roles.isEmpty()
    })
  } else {
    nonOnlyReporters = Immutable.List()
  }

  const status = screening.get('end_date') ? 'Closed' : 'In Progress'

  return (
    <tr key={`screening-${index}`} id={`screening-${screening.get('id')}`}>
      <td>{dateRangeFormatter(screening.toJS())}</td>
      <td>
        <div className='row'>Screening</div>
        <div className='row'>{`(${status})`}</div>
      </td>
      <td>{COUNTIES[incidentCounty]}</td>
      <td>
        <div className='row'>
          <span className='col-md-12 participants'>
            { nonOnlyReporters.map((p) => nameFormatter(p.toJS())).join(', ') }
          </span>
        </div>
        <div className='row'>
          <span className='col-md-6 reporter'>
            {`Reporter: ${reporter ? nameFormatter(Object.assign(reporter.toJS(), {name_default: ''})) : ''}`}
          </span>
          <span className='col-md-6 assignee'>
            {`Worker: ${assignee && assignee.get('last_name') ? assignee.get('last_name') : ''}`}
          </span>
        </div>
      </td>
    </tr>
  )
}

HistoryCardScreening.propTypes = {
  index: PropTypes.number.isRequired,
  screening: PropTypes.object.isRequired,
}

export default HistoryCardScreening
