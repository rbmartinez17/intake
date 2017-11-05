import PropTypes from 'prop-types'
import React from 'react'
import Select from 'react-select'

const WorkerSafetyForm = ({
  alertOptions,
  onBlur,
  onCancel,
  onChange,
  onSave,
  safetyAlerts,
  safetyInformation,
}) => (
  <div className='card-body'>
    <div className='row'>
      <div className='col-md-12'>
        <label htmlFor='safety_alerts'>Worker safety alerts</label>
        <Select
          multi
          tabSelectsValue={false}
          inputProps={{id: 'safety_alerts'}}
          options={alertOptions}
          value={safetyAlerts.value}
          onBlur={() => onBlur('safety_alerts')}
          onChange={
            (alerts) => onChange('safety_alerts',
              alerts.map((alert) => alert.value) || [])
          }
        />
      </div>
    </div>
    <div className='row'>
      <div className='col-md-12'>
        <label className='no-gap' htmlFor='safety_information'>Additional safety information</label>
        <textarea
          id='safety_information'
          onBlur={() => onBlur('safety_information')}
          onChange={({target: {value}}) => onChange('safety_information', value || null)}
          value={safetyInformation.value || ''}
        />
      </div>
    </div>
    <div className='row'>
      <div className='centered'>
        <button className='btn btn-primary' onClick={onSave}>Save</button>
        <button className='btn btn-default' onClick={onCancel}>Cancel</button>
      </div>
    </div>
  </div>
)

WorkerSafetyForm.propTypes = {
  alertOptions: PropTypes.array.isRequired,
  onBlur: PropTypes.func,
  onCancel: PropTypes.func,
  onChange: PropTypes.func,
  onSave: PropTypes.func,
  safetyAlerts: PropTypes.shape({
    errors: PropTypes.array,
    value: PropTypes.array,
  }),
  safetyInformation: PropTypes.shape({
    errors: PropTypes.array,
    value: PropTypes.string,
  }),
}

WorkerSafetyForm.defaultProps = {
  safetyAlerts: {},
  safetyInformation: {},
}

export default WorkerSafetyForm
