var styles = {
  box: {
    width: '60%',
    height: '60%',
    left: 50,
    right: 50,
    backgroundColor: 'black'
  }
};

var SlotWindow = React.createClass ({
  render: function(){
    return(
      <div style={styles.box}>
        <h1>TESTING!</h1>
        <h2>Slot {this.props.slot.id} clicked!</h2>
      </div>
    )
  }
});
