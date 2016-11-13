var mouseOverStyles = {
  margin: '1%',
  width: '18%',
  opacity: 0.5
};

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

    var currentStyle = this.state.hover? mouseOverStyles : cardStyles;

    return(
      <a key={slot.id} href={path}>
        <img style={currentStyle} src={img}
          onMouseEnter={this.onMouseEnterHandler}
          onMouseLeave={this.onMouseLeaveHandler}
         />
      </a>
    )
  }
});
