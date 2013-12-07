package core
{
	public class WallTextureGroup extends ItemsGroup
	{
		/**
		 * Constructor. Creates new instanse of <code>WallTextureGroup</code> object.
		 *
		 * @param	node	XML node from 'config.xml' in correct format.
		 */
		public function WallTextureGroup(node:XML) {
			super(node);
		}
		
		override protected function initializeSingleItem(itemNode:XML):Object {
			return new WallTexture(itemNode);
		}
	}
}