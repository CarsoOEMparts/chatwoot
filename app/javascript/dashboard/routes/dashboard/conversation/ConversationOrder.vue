<script setup>
import { useToggle } from '@vueuse/core'
import { useAlert } from 'dashboard/composables'
import { useRoute } from 'dashboard/composables/route'
import { useStore, useStoreGetters } from 'dashboard/composables/store'
import { useI18n } from 'dashboard/composables/useI18n'
import { useUISettings } from 'dashboard/composables/useUISettings'
import { copyTextToClipboard } from 'shared/helpers/clipboard'
import { computed, onMounted } from 'vue'
import ContactDetailsItem from './ContactDetailsItem.vue'

const props = defineProps({
  attributeType: {
    type: String,
    default: 'conversation_attribute',
  },
  contactId: { type: Number, default: null },
  attributeFrom: {
    type: String,
    required: true,
  },
  emptyStateMessage: {
    type: String,
    default: '',
  },
  startAt: {
    type: String,
    default: 'even',
    validator: value => value === 'even' || value === 'odd',
  },
});

const store = useStore();
const getters = useStoreGetters();
const route = useRoute();
const { t } = useI18n();
const { uiSettings, updateUISettings } = useUISettings();

const [showAllAttributes, toggleShowAllAttributes] = useToggle(false);

const currentChat = computed(() => getters.getSelectedChat.value);

const contactIdentifier = computed(
  () =>
    currentChat.value.meta?.sender?.id ||
    route.params.contactId ||
    props.contactId
);

const contact = computed(() =>
  getters['contacts/getContact'].value(contactIdentifier.value)
);

console.log(contact.value, 'contact');

const customAttributes = computed(() => {
  const attributes = currentChat.value.custom_attributes || {};

  console.log(attributes, 'attributes');
  // filter keys that start with 'order_'
  return Object.fromEntries(
    Object.entries(attributes).filter(([key]) => key.startsWith('order'))
  );
});


const order = computed(() => customAttributes.value);

const orderId = computed(() => order.value.orderId);
const orderStatus = computed(() => order.value.orderStatusText);
const orderDate = computed(() => order.value.orderCreatedAtFormatted);
const orderDispatchDate = computed(() => order.value.orderDispatchDateFormatted);
const orderTotalProfit = computed(() => order.value.orderTotalProfit);

const orderProducts = computed(() => order.value.orderProducts || []);

const conversationId = computed(() => currentChat.value.id);


const showMoreUISettingsKey = computed(
  () => `show_all_attributes_${props.attributeFrom}`
);

const initializeSettings = () => {
  showAllAttributes.value =
    uiSettings.value[showMoreUISettingsKey.value] || false;
};


const onCopy = async attributeValue => {
  await copyTextToClipboard(attributeValue);
  useAlert(t('CUSTOM_ATTRIBUTES.COPY_SUCCESSFUL'));
};

onMounted(() => {
  initializeSettings();
});


</script>

<!-- TODO: After migration to Vue 3, remove the top level div -->
<template>
  <div>
    <div class="mb-6">
      <ContactDetailsItem
        :title="$t('CONVERSATION_ORDER.ORDER_ID')"
        :value="orderId"
        compact
      />
      <ContactDetailsItem
        :title="$t('CONVERSATION_ORDER.STATUS')"
        :value="orderStatus"
        compact
      />
      <ContactDetailsItem
        :title="$t('CONVERSATION_ORDER.CREATED_AT')"
        :value="orderDate"
        compact
      />
      <ContactDetailsItem
        :title="$t('CONVERSATION_ORDER.DISPATCH_DATE')"
        :value="orderDispatchDate"
        compact
      />
      <ContactDetailsItem
        :title="$t('CONVERSATION_ORDER.TOTAL_PROFIT')"
        :value="orderTotalProfit"
        compact
      />
    </div>

    <div>
      <h3 class="text-md font-medium mb-2">{{ $t('CONVERSATION_ORDER.PRODUCTS_TITLE') }}</h3>
      <ul class="space-y-4">
        <li v-for="product in orderProducts" :key="product.orderProductId" class="bg-slate-50 dark:bg-slate-800 rounded-md overflow-hidden">
          <div class="flex items-center p-4">
            <img
              :src="product.productPreviewUrl"
              :alt="product.orderProductTitle"
              class="w-16 h-16 rounded-md mr-4"
            />
            <div class="flex-1">
              <h4 class="text-sm font-semibold text-slate-800 dark:text-slate-100">{{ product.orderProductTitle }}</h4>
              <p class="text-xs text-slate-600 dark:text-slate-400">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.SKU') }}: {{ product.orderProductSKU }}</p>
            </div>
          </div>
          <div class="px-4 pb-4">
            <p class="text-sm text-slate-800 dark:text-slate-100">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.PRICE') }}: {{ product.offerPrice }}</p>
            <p class="text-sm text-slate-600 dark:text-slate-400">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.MARGIN') }}: {{ product.marginValue }}</p>
            <p class="text-sm text-slate-600 dark:text-slate-400">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.QUANTITY') }}: {{ product.orderProductQuantity }}</p>
          </div>
        </li>
      </ul>
    </div>

    <div v-if="orderProducts.length === 0" class="mt-4 text-center text-slate-500">
      {{ $t('CONVERSATION_ORDER.NO_PRODUCTS') }}
    </div>
  </div>
</template>
