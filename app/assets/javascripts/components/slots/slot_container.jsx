var cardStyles = {
  margin: '1%',
  width: '18%'
};

//TODO create a function callback to show SlotWindow
//Pass it as prop to child slotButton

var SlotContainer = React.createClass ({
  getInitialState: function(){
    return {
      displaySlotWindow: false,
      currentSlot: null
    };
  },
  renderSlotButton: function(slot, path){
    return(
        <SlotButton key={slot.id} slot={slot} path={path} displaySlotWindow={this.slotClickHandler} />
    );
  },
  slotClickHandler: function(slot){
    this.setState({
      currentSlot: slot,
      displaySlotWindow: true
    });
  },
  render: function() {
    var slots = this.props.slots;

    return (
      <span>
        <h1>Modal Thingy</h1>
        { slots.map(elem => this.renderSlotButton(elem.slot, elem.path)) }
        { this.state.displaySlotWindow ? <SlotWindow slot={this.state.currentSlot} /> : null }
      </span>
    );
  }
});
