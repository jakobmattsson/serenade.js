require './../spec_helper'
{expect} = require('chai')
{Serenade} = require '../../src/serenade'

describe 'Bound attributes and text nodes', ->
  beforeEach ->
    @setupDom()

  it 'does not add bound attribute if value is undefined in model', ->
    model = { name: 'jonas' }
    @render 'div[id=foo]', model
    expect(@body.querySelector('div')).not.to.have.attribute('id')

  it 'get bound attributes from the model', ->
    model = { name: 'jonas' }
    @render 'div[id=name]', model
    expect(@body).to.have.element('div#jonas')

  it 'get bound text from the model', ->
    model = { name: 'Jonas Nicklas' }
    @render 'div @name', model
    expect(@body.querySelector('div')).to.have.text('Jonas Nicklas')

  it 'sets multiple classes with an array given as the class attribute', ->
    model = { names: ['jonas', 'peter'] }
    @render 'div[class=names]', model
    expect(@body).to.have.element('div.jonas.peter')

  it 'changes bound attributes as they are changed', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'div[id=name]', model
    expect(@body).to.have.element('div#jonas')
    model.set('name', 'peter')
    expect(@body).to.have.element('div#peter')

  it 'removes attributes and reattaches them as they are set to undefined', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'div[id=name]', model
    expect(@body).to.have.element('div#jonas')
    model.set('name', undefined)
    expect(@body.querySelector('div')).not.to.have.attribute('id')
    model.set('name', 'peter')
    expect(@body).to.have.element('div#peter')

  it 'handles value specially', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'input[value=name]', model
    @body.querySelector('input').value = "changed"
    model.set('name', 'peter')
    expect(@body.querySelector('input').value).to.eql('peter')

  it 'handles checked specially', ->
    model = new Serenade.Model
    model.set('checked', true)
    @render 'input[checked=checked]', model

    expect(@body.querySelector('input').checked).to.be.ok
    model.set('checked', false)
    expect(@body.querySelector('input').checked).not.to.be.ok
    model.set('checked', 'schmock')
    expect(@body.querySelector('input').checked).to.be.ok

  it 'changes bound text nodes as they are changed', ->
    model = new Serenade.Model
    model.set('name', 'Jonas Nicklas')
    @render 'div @name', model
    expect(@body.querySelector('div')).to.have.text('Jonas Nicklas')
    model.set('name', 'Peter Pan')
    expect(@body.querySelector('div')).to.have.text('Peter Pan')

  it 'updates multiple classes as the class attribute changes', ->
    model = new Serenade.Model( names: ['jonas', 'peter'] )
    @render 'div[class=names]', model
    expect(@body).to.have.element('div.jonas.peter')
    model.set('names', undefined)
    expect(@body.querySelector('div')).not.to.have.attribute('class')
    model.set('names', 'jonas')
    expect(@body).to.have.element('div.jonas')
    model.set('names', ['harry', 'jonas'])
    expect(@body).to.have.element('div.harry.jonas')

  it 'handles the number zero correctly', ->
    model = { number: 0 }
    @render 'div[data-foo=number] @number', model
    expect(@body.querySelector('div').getAttribute('data-foo')).to.eql("0")
    expect(@body.querySelector('div').textContent).to.eql("0")

  it 'uses model formatter', ->
    model = Serenade({ name: "Jonas" })
    model.property("name", format: (val) -> val.toUpperCase())
    @render 'div[data-name=@name style:color=@name] @name', model
    expect(@body.querySelector('div').getAttribute('data-name')).to.eql("JONAS")
    expect(@body.querySelector('div').style.color).to.eql("JONAS")
    expect(@body.querySelector('div').textContent).to.eql("JONAS")
