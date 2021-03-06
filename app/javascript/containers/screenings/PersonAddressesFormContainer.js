import {connect} from 'react-redux'
import {setField, addAddress, deleteAddress} from 'actions/peopleFormActions'
import AddressesForm from 'views/people/AddressesForm'
import {
  getPersonAddressesSelector,
  getAddressTypeOptionsSelector,
  getStateOptionsSelector,
} from 'selectors/screening/peopleFormSelectors'

const mapStateToProps = (state, {personId}) => ({
  addresses: getPersonAddressesSelector(state, personId).toJS(),
  addressTypeOptions: getAddressTypeOptionsSelector(state).toJS(),
  stateOptions: getStateOptionsSelector().toJS(),
})

const mapDispatchToProps = (dispatch, {personId}) => ({
  addAddress: () => dispatch(addAddress(personId)),
  deleteAddress: (addressIndex) => dispatch(deleteAddress(personId, addressIndex)),
  onChange: (addressIndex, field, value) => {
    dispatch(setField(personId, ['addresses', addressIndex, field], value))
  },
})

export default connect(mapStateToProps, mapDispatchToProps)(AddressesForm)

