var cardStyles = {
  margin: '1%',
  width: '18%'
};

var SlotContainer = React.createClass ({
  renderSlot: function(slot, path){
    return(
        <Slot key={slot.id} slot={slot} path={path} />
    );
  },
  render: function() {
    var slots = this.props.slots;
    
    return (
      <div>
        {slots.map(elem => this.renderSlot(elem.slot, elem.path))}
      </div>
    );
  }
});
