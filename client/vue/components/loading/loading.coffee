module.exports = 
  props:
    diameter:
      type: Number
      default: 30
  template:
    """
    <div class="page-loading">
      <!-- <md-progress-circular md-diameter="diameter" class="md-accent"></md-progress-circular> -->
        loading...
    </div>
    """
