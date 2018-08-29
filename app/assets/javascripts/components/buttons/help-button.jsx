const React = require("react");
const createReactClass = require("create-react-class");
const SmallButton = require("./small-button.jsx");

module.exports = createReactClass({
  displayName: "HelpButton",

  getDefaultProps() {
    return {
      label: "Need some help?",
      key: "help-button"
    };
  },

  render() {
    const classes = ["help-button", "ghost"];
    if (this.props.className != null) {
      classes.push(this.props.className);
    }

    return (
      <SmallButton
        {...Object.assign({}, this.props, { className: classes.join(" ") })}
      />
    );
  }
});
