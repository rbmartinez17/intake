import React from 'react'
import PropTypes from 'prop-types'
import DateField from 'common/DateField'
import SelectField from 'common/SelectField'
import FormField from 'common/FormField'

class Contact extends React.Component {
  componentDidMount() {
    const {
      investigationId,
      actions: {build},
    } = this.props
    build({investigation_id: investigationId})
  }
  render() {
    const {
      investigationId,
      contact: {started_at, status, note, purpose},
      actions: {setField, touchField},
      statuses,
      purposes,
      errors,
    } = this.props

    return (
      <div className='card show double-gap-top'>
        <div className='card-header'>
          <span>{`New Contact - Investigation ${investigationId}`}</span>
        </div>
        <div className='card-body'>
          <form>
            <div className='row'>
              <div className='col-md-6'>
                <div className='row'>
                  <DateField
                    gridClassName='col-md-12'
                    id='started_at'
                    label='Date/Time'
                    value={started_at}
                    onChange={(value) => setField('started_at', value)}
                    onBlur={() => touchField('started_at')}
                    errors={errors.started_at}
                  />
                </div>
                <div className='row'>
                  <SelectField
                    gridClassName='col-md-12'
                    id='status'
                    label='Status'
                    value={status}
                    onChange={(event) => setField('status', event.target.value)}
                    onBlur={() => touchField('status')}
                    errors={errors.status}
                  >
                    <option key='' value='' />
                    {statuses.map(({code, value}) => <option key={code} value={code}>{value}</option>)}
                  </SelectField>
                </div>
                <div className='row'>
                  <SelectField
                    gridClassName='col-md-12'
                    id='purpose'
                    label='Purpose'
                    value={purpose}
                    onChange={(event) => setField('purpose', event.target.value)}
                    errors={errors.purpose}
                  >
                    <option key='' value='' />
                    {purposes.map(({code, value}) => <option key={code} value={code}>{value}</option>)}
                  </SelectField>
                </div>
              </div>
              <div className='col-md-6'>
                <div className='row'>
                  <FormField id='note' gridClassName='col-md-12' label='Contact Notes (Optional)'>
                    <textarea id='note' onChange={(event) => setField('note', event.target.value)}>
                      {note}
                    </textarea>
                  </FormField>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    )
  }
}

Contact.propTypes = {
  actions: PropTypes.object,
  contact: PropTypes.object,
  errors: PropTypes.object,
  investigationId: PropTypes.string.isRequired,
  purposes: PropTypes.array.isRequired,
  statuses: PropTypes.array.isRequired,
}

Contact.defaultProps = {
  errors: {},
}

export default Contact
