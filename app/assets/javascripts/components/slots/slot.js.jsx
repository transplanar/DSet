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

var Slot = React.createClass ({
  getInitialState: function(){
    return {
      hover: false
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
  render: function(){
    var slot = this.props.slot;
    var path = this.props.path;
    var img = slot.image_url;

    var currentStyle = this.state.hover? styles.mouseOver : styles.default;

    return(
      <a href={path}>
        <img style={currentStyle} src={img}
          onMouseEnter={this.onMouseEnterHandler}
          onMouseLeave={this.onMouseLeaveHandler}
         />
         <div style={styles.text}>Test</div>
      </a>
    )
  }
});
