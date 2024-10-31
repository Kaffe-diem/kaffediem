import type { PageLoad } from './$types';
import { OrderService } from '$lib/pocketbase/pb.service';

export const load: PageLoad = async () => {
  const orders = await OrderService.listenForOrders();
  return { orders };
};