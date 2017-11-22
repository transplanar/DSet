// var styles = {
//   default: {
//     margin: '1%',
//     width: '18%',
//     opacity: 1.0
//   },
//   mouseOver: {
//     margin: '1%',
//     width: '22%',
//     opacity: 0.5
//   },
//   //TODO create text overlay
//   text: {
//     display: 'none'
//   }
// }

var SlotButton = React.createClass ({
  getInitialState: function(){
    return {
      hover: false,
      modalIsOpen: false
    };
  },
  onMouseEnterHandler: function(){
    console.log('Mouse Enter');
    this.setState({
      hover: true
    });
  },
  onMouseLeaveHandler: function(){
    console.log('Mouse Leave');
    this.setState({
      hover: false
    });
  },
  displaySlotWindow : function(slot){
    
  },
  onClickHandler: function(){
    var slot = this.props.slot;
    // var displaySlotWindow = this.props.displaySlotWindow;

    console.log('Slot clicked');
    this.displaySlotWindow(slot);
  },
  render: function(){
    var slot = this.props.slot;
    var path = this.props.path;
    var img = slot.image_url;
    
    var styles = {
      default: {
        margin: '1%',
        width: '18%',
        opacity: 1.0
      },
      mouseOver: {
        margin: '1%',
        width: '22%',
        opacity: 0.5
      },
      //TODO create text overlay
      text: {
        display: 'none'
      }
    }
    
    // console.log("Styles are " + styles);

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
