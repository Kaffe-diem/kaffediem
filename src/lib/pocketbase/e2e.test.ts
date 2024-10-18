
import { describe, expect, test } from 'vitest'
import { pb, OrderService } from '$lib/pocketbase/pb.service'



describe("Pocketbase", () => {
    test("should be authenticated", () => {
        expect(pb.authStore.model).toBeDefined();
        expect(pb.authStore.model?.email).toBe(process.env.PUBLIC_PB_ADMIN_EMAIL);
        expect(pb.authStore.model?.username).toBe(process.env.PUBLIC_PB_ADMIN_USERNAME);
    });

    test("should be able to list orders", () => {
        expect(pb.collection("orders").getFullList()).resolves.toBeDefined();
    });

    test("should be able to list drinks", () => {
        expect(pb.collection("drinks").getFullList()).resolves.toBeDefined();
    });

    test("should be able to add an order", () => {
        expect(OrderService.createOrder()).resolves.toBeDefined();
    });
});
