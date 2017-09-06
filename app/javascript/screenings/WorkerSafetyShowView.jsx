import PropTypes from 'prop-types'
import React from 'react'
import ShowField from 'common/ShowField'

const WorkerSafetyShowView = ({safetyAlerts, safetyInformation}) => (
  <div className='card-body'>
    <div className='row'>
      <ShowField gridClassName='col-md-12' label='Worker safety alerts'>
        {safetyAlerts &&
          <ul>{
            safetyAlerts.map((alert_label, index) =>
              (<li key={`SA-${index}`}>{`${alert_label}`}</li>)
            )
          }
          </ul>
        }
      </ShowField>
    </div>
    <div className='row'>
      <ShowField gridClassName='col-md-6' labelClassName='no-gap' label='Additional safety information'>
        {safetyInformation || ''}
      </ShowField>
    </div>
  </div>
)

WorkerSafetyShowView.propTypes = {
  safetyAlerts: PropTypes.object,
  safetyInformation: PropTypes.string,
}
export default WorkerSafetyShowView
