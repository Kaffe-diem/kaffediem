import { test } from "@playwright/test";

// TODO: We are not using click on back button, as this is never recognized by Playwright.
// TODO: We are picking the first order item found.
// Therefore we won't know if there's actually multiple items created for any reason.

test("can create order", async ({ page }) => {
  // create order in /frontdesk
  await page.goto("http://localhost:5173/");
  await page.getByRole("link", { name: "Admin" }).click();
  await page.getByRole("link", { name: "Bestillingsdisk" }).click();
  await page.getByText("Cortado").click();
  await page.getByText("Melk Havre Hel Laktosefri").click();
  await page.locator("label").filter({ hasText: "Liten 10,-" }).click();
  await page.getByRole("button", { name: "+" }).click();
  await page.getByTestId("complete-order-button").click();
  // move to kitchen and move order
  await page.goto("http://localhost:5173/admin");
  await page.getByRole("link", { name: "Kjøkken" }).click();
  await page.getByTestId("order-row").first().click();
  await page.getByTestId("order-row").first().click();
  // move to frontdesk and dispatch order
  await page.goto("http://localhost:5173/admin");
  await page.getByRole("link", { name: "Bestillingsdisk" }).click();
  await page.getByTestId("order-row").first().click();
});
