<template>
    <div class="ahk-main no-marg-b">
        <table>
            <tr v-if="complexPrice">
                <div v-for="a in aff"></div>
            </tr>
            <tr>
                <td class="kms">
                    <span v-if="complexPrice">Complex price</span>
                    <input type="text" v-else v-model="price"/>
                </td>
                <td>
                    <div >
                        <poe-trade-checkbox class="topB" v-model="complexPrice"/>
                    </div>
                    </td>
                <td class="fsd">
                    <button @click="save">Create File</button>
                </td>
                <td>
                    <button @click="reinit">Reinit</button>
                </td>
            </tr>
            <tr>
                <td class="kms"><input type="text" v-model="blockName"/></td>
                <td>
                    <div>
                        <poe-trade-checkbox class="topB" v-model="block"/>
                    </div>
                </td>
                <td class="fsd">
                    <button @click="showBlockInfo">Show Block Info</button>
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
        min-width: 180px
        button
            width: 100%
    .kms
        width: 100%
    .topB
        margin-bottom: 0
</style>
<script>

  import {clearBlock, init, saveCurrentData, showBlockInfo, getMods} from '../helpers/poe.trade'
  import PoeTradeCheckbox from './PoeTradeCheckbox.vue'

  export default {
    components: {PoeTradeCheckbox},
    name: 'app',
    data: function () {
      return {
        status: '',
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
    computed: {
      aff: getMods
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
