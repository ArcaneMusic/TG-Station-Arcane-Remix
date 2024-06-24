import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Modal,
  Section,
  Stack,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

type Data = {
  categories: string[];
  markets: Market[];
  items: Item[];
  money: number;
  viewing_market: string;
  viewing_category: string;
  buying: boolean;
  ltsrbt_built: boolean;
  delivery_methods: DeliveryMethod[];
  delivery_method_description: Record<string, string>;
};

type Market = {
  id: string;
  name: string;
};

type Item = {
  id: string;
  name: string;
  desc: string;
  amount: number;
  cost: number;
};

type DeliveryMethod = {
  name: string;
  price: number;
};

export const BlackMarketAuction = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    categories = [],
    markets = [],
    items = [],
    money,
    viewing_market,
    viewing_category,
  } = data;
  return (
    <Window width={800} height={500} theme="hackerman">
      <ShipmentSelector />
      <Window.Content scrollable>
        <Section
          title="Black Market Auction House"
          buttons={
            <Box inline bold>
              <AnimatedNumber
                value={money}
                format={(value) => formatMoney(value) + ' cr'}
              />
            </Box>
          }
        />
        check check one two
        <Stack fill direction="row">
          <Stack.Item width="70%" grow>
            <Section>
              The bidding block
              <Stack direction="column" fill>
                {/* My Column starts here */}
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item width="50%">
                      <Section>Current auction</Section>
                    </Stack.Item>
                    <Stack.Item width="50%">
                      <Section>identity stuff</Section>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Section>Image goes here.</Section>
                </Stack.Item>
                <Stack fill>
                  <Stack.Item width="70%">
                    <Section>Top Bid</Section>
                  </Stack.Item>
                  <Stack.Item width="30%">
                    <Section>Bid number</Section>
                  </Stack.Item>
                </Stack>

                <Stack.Item>
                  <Section>Map out bid history here.</Section>
                </Stack.Item>
                <Stack>
                  <Stack.Item width="65%">
                    <Section>Time Remaining</Section>
                  </Stack.Item>
                  <Stack.Item width="35%">
                    <Button width="100%">Bid button!</Button>
                  </Stack.Item>
                </Stack>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="30%">
            <Section>Next up on the action block...</Section>
            <Section>Map out the auction queue here</Section>
            <Button width="100%">Reroll Auction block</Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ShipmentSelector = (props) => {
  const { act, data } = useBackend<Data>();
  const { buying, ltsrbt_built, money } = data;
  if (!buying) {
    return null;
  }
  const deliveryMethods = data.delivery_methods.map((method) => {
    const description = data.delivery_method_description[method.name];
    return {
      ...method,
      description,
    };
  });
  return (
    <Modal textAlign="center">
      <Stack mb={1}>
        {deliveryMethods.map((method) => {
          if (method.name === 'LTSRBT' && !ltsrbt_built) {
            return null;
          }
          return (
            <Stack.Item key={method.name} mx={1} width="17.5rem">
              <Box fontSize="30px">{method.name}</Box>
              <Box mt={1}>{method.description}</Box>
              <Button
                mt={2}
                content={formatMoney(method.price) + ' cr'}
                disabled={money < method.price}
                onClick={() =>
                  act('buy', {
                    method: method.name,
                  })
                }
              />
            </Stack.Item>
          );
        })}
      </Stack>
      <Button content="Cancel" color="bad" onClick={() => act('cancel')} />
    </Modal>
  );
};
