import Contact from 'investigations/Contact'
import React from 'react'
import {shallow, mount} from 'enzyme'

describe('Contact', () => {
  function renderContact({
    investigationId = 'ABC123',
    actions = {},
    contact = {},
    errors = {},
    statuses = [],
    purposes = [],
  }) {
    const props = {investigationId, actions, contact, statuses, purposes, errors}
    return shallow(<Contact {...props} />)
  }

  it('displays the investigation Id in the header', () => {
    const component = renderContact({investigationId: 'ABCD1234'})
    const header = component.find('.card-header')
    expect(header.text()).toEqual('New Contact - Investigation ABCD1234')
  })

  it('displays the started at datetime picker', () => {
    const component = renderContact({
      contact: {started_at: '2016-08-11T18:24:22.157Z'},
      errors: {started_at: ['Things are wrong!']},
    })
    const startedAt = component.find('DateField')
    expect(startedAt.props().errors).toEqual(['Things are wrong!'])
    expect(startedAt.props().value).toEqual('2016-08-11T18:24:22.157Z')
  })

  it('changing started at fires setField', () => {
    const setField = jasmine.createSpy('setField')
    const component = renderContact({actions: {setField}, contact: {started_at: ''}})
    component.find('DateField').simulate('change', '123')
    expect(setField).toHaveBeenCalledWith('started_at', '123')
  })

  it('blurring started at fires touchField', () => {
    const touchField = jasmine.createSpy('touchField')
    const component = renderContact({actions: {touchField}, contact: {started_at: ''}})
    component.find('DateField').simulate('blur')
    expect(touchField).toHaveBeenCalledWith('started_at')
  })

  it('displays the status dropdown', () => {
    const component = renderContact({
      contact: {status: 'S'},
      statuses: [
        {code: 'S', value: 'Scheduled'},
        {code: 'A', value: 'Attempted'},
        {code: 'C', value: 'Completed'},
      ],
      errors: {status: ['This could be wrong!']},
    })
    const statusField = component.find("SelectField[id='status']")
    expect(statusField.props().value).toEqual('S')
    expect(statusField.childAt(0).props().value).toEqual('')
    expect(statusField.childAt(1).props().value).toEqual('S')
    expect(statusField.childAt(2).props().value).toEqual('A')
    expect(statusField.childAt(3).props().value).toEqual('C')
    expect(statusField.props().errors).toEqual(['This could be wrong!'])
  })

  it('changing status fires setField', () => {
    const setField = jasmine.createSpy('setField')
    const component = renderContact({actions: {setField}, contact: {status: ''}})
    component.find("SelectField[id='status']").simulate('change', {target: {value: 'C'}})
    expect(setField).toHaveBeenCalledWith('status', 'C')
  })

  it('blurring status at fires touchField', () => {
    const touchField = jasmine.createSpy('touchField')
    const component = renderContact({actions: {touchField}, contact: {status: ''}})
    component.find("SelectField[id='status']").simulate('blur')
    expect(touchField).toHaveBeenCalledWith('status')
  })

  it('displays note', () => {
    const component = renderContact({contact: {note: 'This is a simple contact note'}})
    const noteField = component.find('textarea')
    expect(noteField.text()).toContain('This is a simple contact note')
  })

  it('changing note fires setField', () => {
    const setField = jasmine.createSpy('setField')
    const component = renderContact({
      actions: {setField}, contact: {note: 'This is a simple contact note'},
    })
    component.find('textarea').simulate('change', {target: {value: 'This is a new note'}})
    expect(setField).toHaveBeenCalledWith('note', 'This is a new note')
  })

  it('displays the purpose dropdown', () => {
    const component = renderContact({
      contact: {purpose: '1'},
      purposes: [
        {code: '1', value: 'Investigate Referral'},
        {code: '2', value: 'Consult with Collateral'},
        {code: '3', value: 'Consult with Staff Person'},
      ],
      errors: {purpose: ['This is definately wrong!']},
    })
    const purposeField = component.find("SelectField[id='purpose']")
    expect(purposeField.props().value).toEqual('1')
    expect(purposeField.childAt(0).props().value).toEqual('')
    expect(purposeField.childAt(1).props().value).toEqual('1')
    expect(purposeField.childAt(2).props().value).toEqual('2')
    expect(purposeField.childAt(3).props().value).toEqual('3')
    expect(purposeField.props().errors).toEqual(['This is definately wrong!'])
  })

  it('changing purpose fires setField', () => {
    const setField = jasmine.createSpy('setField')
    const component = renderContact({actions: {setField}, contact: {purpose: ''}})
    component.find("SelectField[id='purpose']").simulate('change', {target: {value: '3'}})
    expect(setField).toHaveBeenCalledWith('purpose', '3')
  })

  it('calls build when the component mounts', () => {
    const build = jasmine.createSpy('build')
    mount(
      <Contact
        investigationId='ABC123'
        actions={{build}}
        contact={{}}
        statuses={[]}
        purposes={[]}
      />
    )
    expect(build).toHaveBeenCalledWith({investigation_id: 'ABC123'})
  })
})
