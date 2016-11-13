var containerStyles = {
  //width: '95%'
}

var cardStyles = {
  margin: '1%',
  width: '18%'
}

var CardSlots = React.createClass ({
  renderSlot: function(slot, path){
    var img = slot.image_url;
    return(
      <a key={slot.id} href={path}><img style={cardStyles} src={img} /></a>
    )
  },
  hoverHandler: function(){

  },
  render: function() {
    var slots = this.props.slots;
    return (
      <div style={containerStyles}>
        {slots.map(elem => this.renderSlot(elem.slot, elem.path))}
      </div>
    );
  }
});
