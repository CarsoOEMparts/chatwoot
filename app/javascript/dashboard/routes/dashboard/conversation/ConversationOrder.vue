<script setup>
import { useToggle } from '@vueuse/core'
import { useAlert } from 'dashboard/composables'
import { useStore, useStoreGetters } from 'dashboard/composables/store'
import { useUISettings } from 'dashboard/composables/useUISettings'
import { copyTextToClipboard } from 'shared/helpers/clipboard'
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
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
const platformURL = window.chatwootConfig.platformURL;
const getters = useStoreGetters();
const route = useRoute();
const { uiSettings, updateUISettings } = useUISettings();
const { t } = useI18n();
const [showAllAttributes, toggleShowAllAttributes] = useToggle(false);

const currentChat = computed(() => getters.getSelectedChat.value);

// const contactIdentifier = computed(
//   () =>
//     currentChat.value.meta?.sender?.id ||
//     route.params.contactId ||
//     props.contactId
// );

// const contact = computed(() =>
//   getters['contacts/getContact'].value(contactIdentifier.value)
// );

// console.log(contact.value, 'contact');
console.log(currentChat.value, 'currentChat');

const order = computed(() => {
  const attributes = 'additional_attributes' in currentChat.value ? currentChat.value.additional_attributes : null;

  if (!attributes) {
    return {};
  }

  return attributes.order;
});


const orderId = computed(() => order.value.orderId);
const orderStatus = computed(() => order.value.orderStatusText);
const orderDate = computed(() => order.value.orderExternalCreatedAtFormatted);
const orderDispatchDate = computed(() => order.value.orderDispatchDateFormatted);
const orderTotalProfit = computed(() => order.value.totalProfit);
const orderExternalOrderId = computed(() => order.value.orderExternalOrderId);
const orderExternalOrderNr = computed(() => order.value.orderExternalOrderNr);

const orderProducts = computed(() => order.value.orderProducts || []);

const conversationId = computed(() => currentChat.value.id);

const trackingNumber = ref(order.value?.trackingNumber || '');

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

// Add new method to save tracking number
const onSaveTrackingNumber = async () => {
  try {
    console.log({
      id: conversationId.value,
      additional_attributes: {
        ...currentChat.value.additional_attributes,
        order: {
          ...order.value,
          trackingNumber: trackingNumber.value,
        },
      },
    }, 'trackingNumber');
    await store.dispatch('updateAdditionalAttributes', {
      conversationId: conversationId.value,
      additionalAttributes: {
        ...currentChat.value.additional_attributes,
        order: {
          ...currentChat.value.additional_attributes.order, 
          trackingNumber: trackingNumber.value,
        },
      },
    });
    
    useAlert(t('CONVERSATION_ORDER.TRACKING_NUMBER_SAVED'));
  } catch (error) {
    useAlert(t('CONVERSATION_ORDER.TRACKING_NUMBER_ERROR'));
  }
};

onMounted(() => {
  initializeSettings();
});


</script>

<!-- TODO: After migration to Vue 3, remove the top level div -->
<template>
  <div>
    <template v-if="order">
      <div class="mb-6">
        <ContactDetailsItem
          :title="$t('CONVERSATION_ORDER.ORDER_ID')"
          :value="orderId"
          compact
          class="mb-4"
        >
          <template #button>
            <woot-button
              type="submit"
              variant="clear"
              size="tiny"
              color-scheme="secondary"
              icon="clipboard"
              class-names="p-0 ml-1"
              @click="onCopy(orderId)"
            />
            <a
              :href="`${platformURL}/marketplace-order?id=${orderId}`"
              class="text-base"
              target="_blank"
              rel="noopener nofollow noreferrer"
            >
              <woot-button
                size="tiny"
                icon="open"
                variant="clear"
                color-scheme="secondary"
              />
            </a>
          </template>
        </ContactDetailsItem>
        <ContactDetailsItem
          :title="$t('CONVERSATION_ORDER.ORDER_EXTERNAL_ID')"
          :value="orderExternalOrderId"
          compact
          class="mb-4"
        >
          <template #button>
            <woot-button
              type="submit"
              variant="clear"
              size="tiny"
              color-scheme="secondary"
              icon="clipboard"
              class-names="p-0 ml-1"
              @click="onCopy(orderExternalOrderId)"
            />
          </template>
        </ContactDetailsItem>
        <ContactDetailsItem v-if="orderExternalOrderNr"
          :title="$t('CONVERSATION_ORDER.ORDER_EXTERNAL_NR')"
          :value="orderExternalOrderNr"
          compact
          class="mb-4"
        >
          <template #button>
            <woot-button
              type="submit"
              variant="clear"
              size="tiny"
              color-scheme="secondary"
              icon="clipboard"
              class-names="p-0 ml-1"
              @click="onCopy(orderExternalOrderNr)"
            />
          </template>
        </ContactDetailsItem>
        <ContactDetailsItem
          :title="$t('CONVERSATION_ORDER.STATUS')"
          :value="orderStatus"
          compact
          class="mb-4"
        />
        <ContactDetailsItem
          :title="$t('CONVERSATION_ORDER.CREATED_AT')"
          :value="orderDate"
          compact
          class="mb-4"
        />
        <ContactDetailsItem
          :title="$t('CONVERSATION_ORDER.DISPATCH_DATE')"
          :value="orderDispatchDate"
          compact
          class="mb-4"
        />
        <ContactDetailsItem
          :title="$t('CONVERSATION_ORDER.TOTAL_PROFIT')"
          :value="`${orderTotalProfit} €`"
          compact
          class="mb-4"
        />
        <div class="w-full">
          <label>
            {{ $t('CONVERSATION_ORDER.TRACKING_NUMBER') }}
            <div class="flex items-baseline">
              <input
                v-model="trackingNumber"
                type="text"
                :placeholder="$t('CONVERSATION_ORDER.TRACKING_NUMBER_PLACEHOLDER')"
              />
              <woot-button
                type="submit"
                variant="clear"
                size="tiny"
                color-scheme="primary"
                icon="save"
                class-names="p-0 ml-1"
                @click="onSaveTrackingNumber"
              />
              <woot-button
                type="submit"
                variant="clear"
                size="tiny"
                color-scheme="secondary"
                icon="clipboard"
                class-names="p-0 ml-1"
                @click="onCopy(trackingNumber)"
              />
            </div>
          </label>
        </div>
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
                <a :href="`${platformURL}?MPN=${product.orderProductMPN}`" class="flex-1 hover:underline" target="_blank" rel="noopener nofollow noreferrer"> 
                  <h4 class="text-sm font-semibold text-slate-800 dark:text-slate-100">
                    {{ product.orderProductTitle }}
                  </h4>
                </a>
              </div>
            </div>
            <div class="px-4 pb-4">
              <p class="text-sm text-slate-800 dark:text-slate-100">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.MPN') }}: 
                <span class="text-slate-600 dark:text-slate-400">
                  {{ product.orderProductMPN }}
                </span>
                <woot-button
                  type="submit"
                  variant="clear"
                  size="tiny"
                  color-scheme="secondary"
                  icon="clipboard"
                  class-names="p-0 ml-1"
                  @click="onCopy(product.orderProductMPN)"
                />
              </p>
              <p class="text-sm text-slate-800 dark:text-slate-100 ">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.SKU') }}: 
                <span class="text-slate-600 dark:text-slate-400">
                  {{ product.orderProductSKU }}
                </span>
                <woot-button
                  type="submit"
                  variant="clear"
                  size="tiny"
                  color-scheme="secondary"
                  icon="clipboard"
                  class-names="p-0 ml-1"
                  @click="onCopy(product.orderProductSKU)"
                />
              </p>
              <p class="text-sm text-slate-800 dark:text-slate-100">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.PRICE') }}: <span class="text-slate-600 dark:text-slate-400">
                {{ product.offerPrice }}
              </span></p>
              <p class="text-sm text-slate-800 dark:text-slate-100">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.MARGIN') }}: <span class="text-slate-600 dark:text-slate-400">
                {{ product.marginValue }} € ({{ product.marginPercent }}%)
              </span></p>
              <p class="text-sm text-slate-800 dark:text-slate-100">{{ $t('CONVERSATION_ORDER.PRODUCTS_TABLE.QUANTITY') }}: <span class="text-slate-600 dark:text-slate-400">
                {{ product.orderProductQuantity }}
              </span></p>
            </div>
          </li>
        </ul>
      </div>

      <div v-if="orderProducts.length === 0" class="mt-4 text-center text-slate-500">
        {{ $t('CONVERSATION_ORDER.NO_PRODUCTS') }}
      </div>
    </template>
    <div v-else>
      {{ $t('CONVERSATION_ORDER.NO_ORDER') }}
    </div>
  </div>
</template>