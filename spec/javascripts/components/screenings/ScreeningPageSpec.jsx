import * as IntakeConfig from 'common/config'
import React from 'react'
import {ScreeningPage} from 'screenings/ScreeningPage'
import {shallow} from 'enzyme'

describe('ScreeningPage', () => {
  const sdmPath = 'https://ca.sdmdata.org'
  let isFeatureActiveSpy

  beforeEach(() => {
    spyOn(IntakeConfig, 'isFeatureInactive').and.returnValue(true)
    isFeatureActiveSpy = spyOn(IntakeConfig, 'isFeatureActive').and.returnValue(false)
    spyOn(IntakeConfig, 'sdmPath').and.returnValue(sdmPath)
  })

  function renderScreeningPage({
    actions = {},
    editable = true,
    loaded = true,
    params = {},
    participants = [],
    hasApiValidationErrors = false,
    submitReferralErrors = [],
    ...args
  }) {
    const props = {
      actions,
      editable,
      loaded,
      params,
      participants,
      hasApiValidationErrors,
      submitReferralErrors,
      ...args,
    }
    return shallow(<ScreeningPage {...props} />, {disableLifecycleMethods: true})
  }
  function renderScreeningPageWithLifecycle({
    actions: {
      setPageMode = () => null,
      fetchScreening = () => null,
      fetchRelationships = () => null,
      fetchHistoryOfInvolvements = () => null,
    },
    participants = [],
    screening = {},
    params = {},
    editable,
  }) {
    const props = {
      actions: {
        setPageMode,
        fetchScreening,
        fetchRelationships,
        fetchHistoryOfInvolvements,
      },
      params,
      participants,
      screening,
      editable,
    }
    return shallow(<ScreeningPage {...props}/>)
  }

  describe('componentDidMount', () => {
    it("sets the page mode to 'edit' when url mode is 'edit' and editable is true", () => {
      const setPageMode = jasmine.createSpy('setPageMode')
      renderScreeningPageWithLifecycle({
        editable: true,
        actions: {setPageMode},
        params: {mode: 'edit'},
      })
      expect(setPageMode).toHaveBeenCalledWith('edit')
    })

    it("sets the page mode to 'show' when url mode is 'show' and editable is true", () => {
      const setPageMode = jasmine.createSpy('setPageMode')
      renderScreeningPageWithLifecycle({
        editable: true,
        actions: {setPageMode},
        params: {mode: 'show'},
      })
      expect(setPageMode).toHaveBeenCalledWith('show')
    })

    describe('when the screening page URL ID is present', () => {
      const id = '222'
      let fetchScreening
      let fetchRelationships
      let fetchHistoryOfInvolvements
      beforeEach(() => {
        fetchScreening = jasmine.createSpy('fetchScreening')
        fetchRelationships = jasmine.createSpy('fetchRelationships')
        fetchHistoryOfInvolvements = jasmine.createSpy('fetchHistoryOfInvolvements')
        renderScreeningPageWithLifecycle({
          actions: {fetchScreening, fetchRelationships, fetchHistoryOfInvolvements},
          params: {id},
        })
      })

      it('fetches screening from the url ID', () => {
        expect(fetchScreening).toHaveBeenCalledWith(id)
      })

      it('fetches relationships for the screening from the url ID', () => {
        expect(fetchRelationships).toHaveBeenCalledWith('screenings', id)
      })

      it('fetches HOI for the screening from the url ID', () => {
        expect(fetchHistoryOfInvolvements).toHaveBeenCalledWith('screenings', id)
      })
    })
  })

  describe('render', () => {
    it('renders a sidebar', () => {
      expect(renderScreeningPage({}).find('ScreeningSideBar').exists()).toBe(true)
    })

    it('renders a page header', () => {
      expect(renderScreeningPage({}).find('Connect(PageHeader)').exists()).toBe(true)
    })

    it('passes the screening title to the page header', () => {
      const screeningPage = renderScreeningPage({screeningTitle: 'Screening 1'})
      const pageHeader = screeningPage.find('Connect(PageHeader)')
      expect(pageHeader.props().pageTitle).toEqual('Screening 1')
    })

    it('passes buttons to the screening header', () => {
      const pageHeader = renderScreeningPage({}).find('Connect(PageHeader)')
      expect(pageHeader.props().button.type).toEqual('button')
    })

    describe('with errors', () => {
      it('renders the error detail card', () => {
        const submitReferralErrors = ['a', 'b', 'c']
        const component = renderScreeningPage({
          mode: 'edit',
          submitReferralErrors,
          hasApiValidationErrors: true,
        })
        const card = component.find('ErrorDetail')
        expect(card.exists()).toEqual(true)
        expect(card.props().errors).toEqual(submitReferralErrors)
      })
    })
    describe('without errors', () => {
      it('does not render the error detail card', () => {
        const submitReferralErrors = []
        const component = renderScreeningPage({
          mode: 'edit',
          submitReferralErrors,
          hasApiValidationErrors: false,
        })
        const card = component.find('ErrorDetail')
        expect(card.exists()).toEqual(false)
      })
    })
    describe('in edit mode', () => {
      let component
      beforeEach(() => {
        component = renderScreeningPage({mode: 'edit'})
      })

      it('does not render home and edit links', () => {
        expect(component.find({to: '/'}).exists()).toEqual(false)
        expect(component.find({to: '/screenings/1/edit'}).exists()).toEqual(false)
      })

      it('renders the history card', () => {
        const card = component.find('Connect(HistoryOfInvolvement)')
        expect(card.exists()).toEqual(true)
      })

      it('renders the relations card', () => {
        const card = component.find('Connect(RelationshipsCard)')
        expect(card.exists()).toEqual(true)
      })

      it('renders the referral id, if present', () => {
        const heading = renderScreeningPage({
          mode: 'show',
          referralId: '123456',
        }).find('h1')
        expect(heading.text()).toEqual('Referral #123456')
      })

      it('renders the search card', () => {
        expect(component.find('Connect(PersonSearchForm)').exists()).toEqual(true)
      })
    })

    describe('in show mode', () => {
      let component
      beforeEach(() => {
        component = renderScreeningPage({
          mode: 'show',
          participants: [{id: 'id-1'}, {id: 'id-2'}],
          params: {id: '1'},
        })
      })

      it('renders the home and edit link', () => {
        const homeLink = component.find({children: 'Home', to: '/'})
        const editLink = component.find({children: 'Edit', to: '/screenings/1/edit'})
        expect(homeLink.exists()).toBe(true)
        expect(editLink.exists()).toBe(true)
      })

      it('renders the screening information card', () => {
        const card = component.find({title: 'Screening Information'})
        expect(card.exists()).toEqual(true)
      })

      it('renders the participants card for each participant', () => {
        const cards = component.find('PersonCardView')
        expect(cards.length).toEqual(2)
      })

      it('renders the narrative card', () => {
        const card = component.find({title: 'Narrative'})
        expect(card.exists()).toEqual(true)
      })

      it('renders the incident information show card', () => {
        const card = component.find({title: 'Incident Information'})
        expect(card.exists()).toEqual(true)
      })

      it('renders the allegations card', () => {
        const card = component.find({title: 'Allegations'})
        expect(card.exists()).toEqual(true)
      })

      it('renders the worker safety card', () => {
        const card = component.find({title: 'Worker Safety'})
        expect(card.exists()).toEqual(true)
      })

      it('renders the history card', () => {
        const card = component.find('Connect(HistoryOfInvolvement)')
        expect(card.exists()).toEqual(true)
      })

      it('renders the cross report show card', () => {
        const card = component.find({title: 'Cross Report'})
        expect(card.exists()).toEqual(true)
      })

      it('renders the decision show card', () => {
        const card = component.find({title: 'Decision'})
        expect(card.exists()).toEqual(true)
      })

      it('renders the person search card', () => {
        expect(component.find('Connect(PersonSearchForm)').exists()).toEqual(true)
      })
    })
  })

  describe('when screening is not loaded', () => {
    it('renders an empty div', () => {
      isFeatureActiveSpy.and.returnValue(true)
      expect(renderScreeningPage({loaded: false}).find('.container').childAt(0).html()).toEqual('<div></div>')
    })
  })

  describe('when the screening page is unmounted', () => {
    let actions

    beforeEach(() => {
      actions = {
        clearScreening: jasmine.createSpy('clearScreening'),
        clearRelationships: jasmine.createSpy('clearRelationships'),
        clearHistoryOfInvolvement: jasmine.createSpy('clearHistoryOfInvolvement'),
        clearPeople: jasmine.createSpy('clearPeople'),
      }
    })

    it('clears the screening', () => {
      const screeningPage = renderScreeningPage({actions})
      screeningPage.unmount()
      expect(actions.clearScreening).toHaveBeenCalled()
    })

    it('clears relationships', () => {
      const screeningPage = renderScreeningPage({actions})
      screeningPage.unmount()
      expect(actions.clearRelationships).toHaveBeenCalled()
    })

    it('clears HOI', () => {
      const screeningPage = renderScreeningPage({actions})
      screeningPage.unmount()
      expect(actions.clearHistoryOfInvolvement).toHaveBeenCalled()
    })

    it('clears people', () => {
      const screeningPage = renderScreeningPage({actions})
      screeningPage.unmount()
      expect(actions.clearPeople).toHaveBeenCalled()
    })
  })
})
