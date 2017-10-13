var styles = {
  default: {
    margin: '1%',
    width: '18%'
  },
  mouseOver: {
    margin: '1%',
    width: '18%',
    opacity: 0.5
  },
  //TODO create text overlay
  text: {
    display: 'none'
  }
}

var SlotButton = React.createClass ({
  getInitialState: function(){
    return {
      hover: false,
      modalIsOpen: false
    };
  },
  onMouseEnterHandler: function(){
    this.setState({
      hover: true
    });
  },
  onMouseLeaveHandler: function(){
    this.setState({
      hover: false
    });
  },
  onClickHandler: function(){
    var slot = this.props.slot;
    var displaySlotWindow = this.props.displaySlotWindow;

    console.log('Slot clicked');
    displaySlotWindow(slot);
  },
  render: function(){
    var slot = this.props.slot;
    var path = this.props.path;
    var img = slot.image_url;

    var currentStyle = this.state.hover? styles.mouseOver : styles.default;

    return(
      <div>
        <span>
          <img style={currentStyle} src={img}
            onMouseEnter={this.onMouseEnterHandler}
            onMouseLeave={this.onMouseLeaveHandler}
            onClick={this.onClickHandler}
           />
           <div style={styles.text}>Test</div>
        </span>
      </div>
    )

    /*
    return(
      <a href={path}>
        <img style={currentStyle} src={img}
          onMouseEnter={this.onMouseEnterHandler}
          onMouseLeave={this.onMouseLeaveHandler}
          onClick={this.onClickHandler}
         />
      </a>
    )*/
  }
});
