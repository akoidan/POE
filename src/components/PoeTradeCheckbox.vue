<template>
    <div class="switch">
        <input id="ahk1" value="" type="radio"  v-model="picked"><span
            class="custom radio checked"></span>
        <label for="ahk1" onclick="">Off</label>
        <input id="ahk2" v-model="picked" value="x" type="radio"><span class="custom radio"></span>
        <label for="ahk2" onclick="">On</label>
        <span></span>
    </div>
</template>
<script>

  import {saveCurrentData} from '../helpers/poe.trade'

  export default {
    name: 'poe-trade-checkbox',
    props: ['value'],
    data: function() {
      return {picked: false}
    },
    created: function () {
      this.picked = this.value ? 'x' : '';
    },
    watch: {
      picked: function() {
        this.$emit('input', this.picked === 'x');
      }
    }
  }
</script>
