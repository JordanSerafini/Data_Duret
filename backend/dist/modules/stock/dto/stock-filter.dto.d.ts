import { PaginationDto } from '../../../common/dto';
export declare enum SortOrder {
    ASC = "ASC",
    DESC = "DESC"
}
export declare class StockFilterDto extends PaginationDto {
    search?: string;
    famille?: string;
    sortField?: string;
    sortOrder?: SortOrder;
    societeId?: number;
}
