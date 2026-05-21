import frappe
from frappe.tests import IntegrationTestCase


class TestLabSampleItem(IntegrationTestCase):
    def test_create_item(self):
        doc = frappe.get_doc(
            {
                "doctype": "Lab Sample Item",
                "item_name": "Test Item",
                "description": "Integration test",
                "status": "Draft",
            }
        )
        doc.insert()
        self.assertTrue(doc.name)
        doc.delete()
