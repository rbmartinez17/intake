import {createReducer} from 'utils/createReducer'
import {List, fromJS} from 'immutable'
import {FETCH_SYSTEM_CODES_SUCCESS} from 'actions/systemCodesActions'
import {findByCategory} from 'selectors'
const ALLEGATION_TYPE = 'allegation_type'

export default createReducer(List(), {
  [FETCH_SYSTEM_CODES_SUCCESS](state, {systemCodes}) {
    return fromJS(findByCategory(systemCodes, ALLEGATION_TYPE))
  },
})