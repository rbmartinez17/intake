export const SET_PEOPLE_FORM_FIELD = 'SET_PEOPLE_FORM_FIELD'
export const TOUCH_PEOPLE_FORM_FIELD = 'TOUCH_PEOPLE_FORM_FIELD'
export const TOUCH_ALL_PEOPLE_FORM_FIELDS = 'TOUCH_ALL_PEOPLE_FORM_FIELDS'
export const ADD_PEOPLE_FORM_ADDRESS = 'ADD_PEOPLE_FORM_ADDRESS'
export const DELETE_PEOPLE_FORM_ADDRESS = 'DELETE_PEOPLE_FORM_ADDRESS'
export const ADD_PEOPLE_FORM_PHONE_NUMBER = 'ADD_PEOPLE_FORM_PHONE_NUMBER'
export const DELETE_PEOPLE_FORM_PHONE_NUMBER = 'DELETE_PEOPLE_FORM_PHONE_NUMBER'

export const setField = (personId, fieldSet, value) => ({
  type: SET_PEOPLE_FORM_FIELD,
  payload: {personId, fieldSet, value},
})
export const touchField = (personId, field) => ({
  type: TOUCH_PEOPLE_FORM_FIELD,
  payload: {personId, field},
})
export const touchAllFields = (personId) => ({
  type: TOUCH_ALL_PEOPLE_FORM_FIELDS,
  payload: {personId},
})
export const addAddress = (personId) => ({type: ADD_PEOPLE_FORM_ADDRESS, payload: {personId}})
export const deleteAddress = (personId, addressIndex) => ({type: DELETE_PEOPLE_FORM_ADDRESS, payload: {personId, addressIndex}})
export const addPhone = (personId) => ({type: ADD_PEOPLE_FORM_PHONE_NUMBER, payload: {personId}})
export const deletePhone = (personId, phoneIndex) => ({type: DELETE_PEOPLE_FORM_PHONE_NUMBER, payload: {personId, phoneIndex}})
