package core
{
	public class FloorTextureGroup extends ItemsGroup
	{
		/**
		 * Constructor. Creates new instanse of <code>FloorTextureGroup</code> object.
		 *
		 * @param	node	XML node from 'config.xml' in correct format.
		 */
		public function FloorTextureGroup(node:XML) {
			super(node);
		}
		
		override protected function initializeSingleItem(itemNode:XML):Object {
			return new FloorTexture(itemNode);
		}
	}
}