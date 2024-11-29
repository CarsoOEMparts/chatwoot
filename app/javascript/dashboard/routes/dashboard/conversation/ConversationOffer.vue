<script setup>
import { useToggle } from '@vueuse/core'
import { useAlert } from 'dashboard/composables'
import { useStore, useStoreGetters } from 'dashboard/composables/store'
import { useUISettings } from 'dashboard/composables/useUISettings'
import { copyTextToClipboard } from 'shared/helpers/clipboard'
import { computed, onMounted } from 'vue'
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

const platformURL = window.chatwootConfig.platformURL;
const store = useStore();
const getters = useStoreGetters();
const route = useRoute();
const { uiSettings, updateUISettings } = useUISettings();
const { t } = useI18n();
const [showAllAttributes, toggleShowAllAttributes] = useToggle(false);

const currentChat = computed(() => getters.getSelectedChat.value);

const offer = computed(() => {
  return currentChat.value.additional_attributes?.offer;
});
const productTitle = computed(() => {
  return offer.value.productTitle1 ? offer.value.productTitle1.en : null;
});

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
    <template v-if="offer">
      <div class="flex items-center mb-4">
        <img
          :src="offer.productPreview"
        :alt="offer.title"
          class="w-16 h-16 rounded-md mr-4"
        />
        <a :href="`${platformURL}/marketplace-offer?q=${offer.offerMPN}`" class="flex-1 hover:underline" target="_blank" rel="noopener nofollow noreferrer"> 
          <h4 class="text-sm font-semibold text-slate-800 dark:text-slate-100">
            {{ productTitle }}
          </h4>
        </a>
      </div>
      <div>
        <ContactDetailsItem
          :title="$t('CONVERSATION_OFFER.OFFER_ID')"
          :value="offer.offerId"
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
              @click="onCopy(offer.offerId)"
            />
          </template>
        </ContactDetailsItem>
        <ContactDetailsItem
          :title="$t('CONVERSATION_OFFER.OFFER_EXTERNAL_ID')"
          :value="offer.offerExternalId"
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
              @click="onCopy(offer.offerExternalId)"
            />
            <a
              :href="`${offer.offerExternalLink}`"
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
          :title="$t('CONVERSATION_OFFER.MPN')"
          :value="offer.offerMPN"
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
              @click="onCopy(offer.offerMPN)"
            />
          </template>
        </ContactDetailsItem>
        <ContactDetailsItem
          :title="$t('CONVERSATION_OFFER.PRICE')"
          :value="offer.offerMarketplaceOfferPrice"
          compact
          class="mb-4"
        />
        <ContactDetailsItem
          :title="$t('CONVERSATION_OFFER.MARGIN')"
          :value="`${offer.marginValue} € (${offer.marginPercent}%)`"
          compact
          class="mb-4"
        />
      </div>
    </template>
    <div v-else>
      {{ $t('CONVERSATION_OFFER.NO_OFFER') }}
    </div>
  </div>
</template>
