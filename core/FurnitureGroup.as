package core
{
	public class FurnitureGroup extends ItemsGroup
	{
		/**
		 * Constructor. Creates new instanse of <code>FurnitureGroup</code> object.
		 *
		 * @param	node	XML node from 'config.xml' in correct format.
		 */
		public function FurnitureGroup(node:XML) {
			super(node);
		}
		
		override protected function initializeSingleItem(itemNode:XML):Object {
			return new Furniture(itemNode);
		}
	}
}