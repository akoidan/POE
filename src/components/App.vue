<template>
    <div class="ahk-main no-marg-b">
        <table>
            <tr v-if="aff">
                <div v-for="a in aff"></div>
            </tr>
            <tr>
                <td>
                    <input type="text" v-model="price"/>
                </td>
                <td>
                    <div class="inline checbw">
                        <poe-trade-checkbox class="checb" v-model="complexPrice"/>
                    </div>
                    </td>
                <td class="fsd">
                    <button @click="save">Create File</button>
                </td>
                <td class="td2">
                    <button @click="reinit">Reinit</button>
                </td>
            </tr>
            <tr>
                <td><input type="text" class=" in2 inline" v-model="blockName"/></td>
                <td>
                    <div class="inline checbw">
                        <poe-trade-checkbox class="checb" v-model="block"/>
                    </div>
                </td>
                <td>
                    <button class="bbtn1 inline" @click="showBlockInfo">Show Block Info</button>
                </td>
                <td >
                    <button @click="clear">Clear</button>
                </td>
            </tr>
        </table>
    </div>
</template>
<style lang="sass" scoped>
    .fsd
        width: 1px
        button
            width: 100%
    .checbw
        position: relative
        width: 85px
        .checb
            position: absolute
            top: -20px
            left: 10px
    .in2
        width: calc(100% - 90px)
    .t23
        width: calc(100% - 80px)
        vertical-align: top
        padding-top: 15px
        padding-left: 5px
        display: inline-block
    .inline
        display: inline-block
    .bbtn1
        width: 180px
    .text
        vertical-align: top
        width: calc(100% - 190px)
        padding-right: 10px
        > *
            display: inline-block
    table
        width: 100%
    .ahk-main
        padding: 0 10px
    .checb
        margin-bottom: 0
        width: 65px
    .td2
        width: 135px
    button
        width: 125px


</style>
<script>

  import {clearBlock, init, saveCurrentData, showBlockInfo} from '../helpers/poe.trade'
  import PoeTradeCheckbox from './PoeTradeCheckbox.vue'

  export default {
    components: {PoeTradeCheckbox},
    name: 'app',
    data: function () {
      return {
        status: '',
        aff: [],
        block: false,
        blockName: '',
        complexPrice: false,
        price: 'My offer is 1 chaos'
      }
    },
    created: function() {
      let innerHTML = document.querySelector('#base_chosen a span').innerHTML;
      if (innerHTML === 'any') {
        innerHTML = '';
      }
      this.blockName = document.getElementById('name').value || innerHTML;
    },
    methods: {
      reinit: function() {
        init();
      },
      save: function () {
        saveCurrentData(this.block && this.blockName? this.blockName : false, this.price);
      },
      clear: function() {
        clearBlock(this.blockName);
      },
      showBlockInfo: function () {
        alert(showBlockInfo(this.blockName));
      }
    }
  }
</script>
