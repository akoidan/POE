<template>
    <div class="inline">
        <div>
            <label>Amount</label>
            <input type="number" v-model.number="amount"/>
        </div>
        <div>
            <label>Price limit</label>
            <input type="number" v-model.number="price"/>
        </div>
        <button @click="create">Create</button>
    </div>
</template>
<style lang="sass" scoped>
    .inline
        > div
            display: inline-block
            width: calc(50% - 90px)
            margin-right: 5px
        > button
            width: 150px
</style>
<script>

  import {clearBlock, init, saveCurrencyData, saveCurrentData, showBlockInfo} from '../helpers/poe.trade'
  import PoeTradeCheckbox from './PoeTradeCheckbox.vue'

  export default {
    name: 'app-currency',
    data: function () {
      return {
        amount: 0,
        price: 0,
      }
    },
    methods: {
      create: function() {
        saveCurrencyData(this.amount, this.price);
      },
    }
  }
</script>
